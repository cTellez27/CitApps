-- Script de Base de Datos para Clientes (Fase 6)
-- Ejecuta este script en el editor SQL de tu panel de Supabase (SQL Editor -> New Query)

-- 1. Crear tabla de Clientes (Clients)
CREATE TABLE IF NOT EXISTS public.clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID NOT NULL REFERENCES public.barbershops(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Habilitar RLS (Row Level Security)
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

-- 3. Crear Políticas de RLS para Clients
CREATE POLICY "Permitir lectura de clientes a todos los miembros de la barbería" ON public.clients
    FOR SELECT USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Permitir gestión de clientes a miembros de la barbería" ON public.clients
    FOR ALL USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));
