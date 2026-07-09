-- Script de inicialización de Base de Datos para Supabase
-- Ejecuta este script en el editor SQL de tu panel de Supabase (SQL Editor -> New Query)

-- 1. Habilitar la extensión UUID si no está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Crear tabla de Barberías (Barbershops)
CREATE TABLE IF NOT EXISTS public.barbershops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    instagram VARCHAR(255),
    currency_symbol VARCHAR(5) DEFAULT '$',
    currency_code VARCHAR(3) DEFAULT 'MXN',
    appointment_interval INT DEFAULT 30,
    timezone VARCHAR(50) DEFAULT 'America/Mexico_City',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Crear tabla de Perfiles de Usuario (Profiles)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE SET NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL CHECK (role IN ('owner', 'admin', 'barber', 'receptionist')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Crear función disparadora (Trigger Function) para sincronizar auth.users con public.profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, barbershop_id, is_active)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuario Nuevo'),
    COALESCE(new.raw_user_meta_data->>'role', 'owner'), -- El rol por defecto es owner al registrarse
    (new.raw_user_meta_data->>'barbershop_id')::uuid,
    true
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Crear el disparador (Trigger) en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. Habilitar RLS (Row Level Security)
ALTER TABLE public.barbershops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 7. Crear Políticas de RLS para Barbershops
CREATE POLICY "Permitir lectura de barbería para usuarios de la misma" ON public.barbershops
    FOR SELECT USING (id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Permitir actualización de barbería a propietarios (owner)" ON public.barbershops
    FOR UPDATE USING (
        id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid())
        AND (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'owner'
    );

-- 8. Crear Políticas de RLS para Profiles
CREATE POLICY "Permitir lectura de perfiles de la misma barbería" ON public.profiles
    FOR SELECT USING (barbershop_id = (SELECT barbershop_id FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Permitir actualización del propio perfil" ON public.profiles
    FOR UPDATE USING (id = auth.uid());
