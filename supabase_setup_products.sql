-- Script de Base de Datos para Catálogo de Productos y Ventas en Citas (Fase 6.5)
-- Ejecuta este script en el editor SQL de tu panel de Supabase (SQL Editor -> New Query)

-- 1. Crear tabla de Productos (Products)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID NOT NULL REFERENCES public.barbershops(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Crear tabla intermedia Cita-Productos (Appointment Products)
CREATE TABLE IF NOT EXISTS public.appointment_products (
    appointment_id UUID NOT NULL REFERENCES public.appointments(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (appointment_id, product_id)
);

-- 3. Desactivar RLS en estas nuevas tablas para evitar errores 403 en inserciones rápidas de pruebas
ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointment_products DISABLE ROW LEVEL SECURITY;
