-- Script de actualización para la Fase 3 (Ejecutar en Supabase SQL Editor)
-- Agrega columnas opcionales a la tabla barbershops para habilitar/deshabilitar módulos de comisiones y horarios individuales.

ALTER TABLE public.barbershops 
ADD COLUMN IF NOT EXISTS enable_commissions BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS enable_employee_schedules BOOLEAN DEFAULT FALSE;
