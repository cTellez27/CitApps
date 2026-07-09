-- Script de Base de Datos para Servicios (Fase 4)
-- Ejecuta este script en el editor SQL de tu panel de Supabase (SQL Editor -> New Query)

-- 1. Crear tabla de Servicios
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID NOT NULL REFERENCES public.barbershops(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    duration_minutes INT NOT NULL CHECK (duration_minutes >= 15),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Crear tabla intermedia Servicio-Empleado (Relación N a N)
CREATE TABLE IF NOT EXISTS public.employee_services (
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
    PRIMARY KEY (service_id, employee_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Habilitar RLS (Row Level Security)
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_services ENABLE ROW LEVEL SECURITY;

-- 4. Crear Políticas de RLS para Services
CREATE POLICY "Permitir lectura de servicios a todos los usuarios de la misma barbería" ON public.services
    FOR SELECT USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Permitir gestión de servicios a dueños y administradores" ON public.services
    FOR ALL USING (
        barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        AND (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('owner', 'admin')
    );

-- 5. Crear Políticas de RLS para Employee-Services (Relación N a N)
CREATE POLICY "Permitir lectura de asignación de servicios" ON public.employee_services
    FOR SELECT USING (
        service_id IN (
            SELECT id FROM public.services 
            WHERE barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        )
    );

CREATE POLICY "Permitir gestión de asignación de servicios a dueños y administradores" ON public.employee_services
    FOR ALL USING (
        service_id IN (
            SELECT id FROM public.services 
            WHERE barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        )
        AND (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('owner', 'admin')
    );
