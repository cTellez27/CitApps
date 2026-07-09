-- Script de Base de Datos para Citas y Agenda (Fase 5)
-- Ejecuta este script en el editor SQL de tu panel de Supabase (SQL Editor -> New Query)

-- 1. Crear tabla de Citas (Appointments)
CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID NOT NULL REFERENCES public.barbershops(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
    client_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_email VARCHAR(255),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL CHECK (end_time > start_time),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
); 

-- 2. Crear tabla intermedia Cita-Servicios (Appointment Services)
CREATE TABLE IF NOT EXISTS public.appointment_services (
    appointment_id UUID NOT NULL REFERENCES public.appointments(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (appointment_id, service_id)
);

-- 3. Habilitar RLS (Row Level Security)
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointment_services ENABLE ROW LEVEL SECURITY;

-- 4. Crear Políticas de RLS para Appointments
CREATE POLICY "Permitir lectura de citas a todos los miembros de la barbería" ON public.appointments
    FOR SELECT USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Permitir agendar y gestionar citas a miembros de la barbería" ON public.appointments
    FOR ALL USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

-- 5. Crear Políticas de RLS para Appointment Services (Relación N a N)
CREATE POLICY "Permitir lectura de servicios de citas" ON public.appointment_services
    FOR SELECT USING (
        appointment_id IN (
            SELECT id FROM public.appointments 
            WHERE barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        )
    );

CREATE POLICY "Permitir gestión de servicios de citas" ON public.appointment_services
    FOR ALL USING (
        appointment_id IN (
            SELECT id FROM public.appointments 
            WHERE barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        )
    );
