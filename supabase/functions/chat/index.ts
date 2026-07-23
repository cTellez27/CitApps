import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { SYSTEM_INSTRUCTIONS } from "./system_instructions.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ChatMessageInput {
  role: "user" | "assistant" | "system";
  content: string;
}

interface RequestPayload {
  messages?: ChatMessageInput[];
  prompt?: string;
}

serve(async (req) => {
  // Manejo de preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Método no permitido. Usa POST." }),
        { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Verificar clave de Groq (o Gemini como alternativa)
    const groqApiKey = Deno.env.get("GROQ_API_KEY");
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");

    const payload: RequestPayload = await req.json();
    let formattedMessages: Array<{ role: string; content: string }> = [];

    // System prompt estricto con los guardrails
    formattedMessages.push({
      role: "system",
      content: SYSTEM_INSTRUCTIONS,
    });

    if (payload.messages && Array.isArray(payload.messages) && payload.messages.length > 0) {
      payload.messages.forEach((msg) => {
        formattedMessages.push({
          role: msg.role === "assistant" ? "assistant" : "user",
          content: msg.content,
        });
      });
    } else if (payload.prompt) {
      formattedMessages.push({
        role: "user",
        content: payload.prompt,
      });
    } else {
      return new Response(
        JSON.stringify({ error: "Se requiere 'messages' o 'prompt' en el cuerpo de la solicitud." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let replyText: string | null = null;

    // ── PROCESAR CON GROQ API (100% GRATIS) ──
    if (groqApiKey) {
      const groqModels = [
        "llama-3.3-70b-versatile",
        "llama3-70b-8192",
        "llama3-8b-8192",
        "gemma2-9b-it",
      ];

      for (const model of groqModels) {
        try {
          const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${groqApiKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              model: model,
              messages: formattedMessages,
              temperature: 0.2,
              max_tokens: 800,
            }),
          });

          if (response.ok) {
            const data = await response.json();
            replyText = data.choices?.[0]?.message?.content || null;
            if (replyText) {
              console.log(`Respuesta obtenida con éxito desde Groq usando: ${model}`);
              break;
            }
          } else {
            console.warn(`Groq modelo ${model} falló con status ${response.status}`);
          }
        } catch (err) {
          console.error(`Error en Groq fetch para ${model}:`, err);
        }
      }
    }

    // ── FALLBACK A GEMINI SI NO HAY RESPUESTA DE GROQ ──
    if (!replyText && geminiApiKey) {
      const geminiModels = ["gemini-1.5-flash-8b", "gemini-2.0-flash-lite", "gemini-1.5-flash"];
      for (const modelName of geminiModels) {
        try {
          const geminiContents = formattedMessages
            .filter((m) => m.role !== "system")
            .map((m) => ({
              role: m.role === "assistant" ? "model" : "user",
              parts: [{ text: m.content }],
            }));

          const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${geminiApiKey}`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                system_instruction: { parts: [{ text: SYSTEM_INSTRUCTIONS }] },
                contents: geminiContents,
                generationConfig: { temperature: 0.2, maxOutputTokens: 800 },
              }),
            }
          );

          if (response.ok) {
            const data = await response.json();
            replyText = data.candidates?.[0]?.content?.parts?.[0]?.text || null;
            if (replyText) break;
          }
        } catch (e) {
          console.error("Gemini fallback error:", e);
        }
      }
    }

    if (replyText) {
      return new Response(
        JSON.stringify({ reply: replyText }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: "No se pudo conectar con el servicio de IA. Verifica tu GROQ_API_KEY." }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error inesperado en Edge Function:", error);
    return new Response(
      JSON.stringify({ error: "Ocurrió un error interno procesando tu consulta." }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
