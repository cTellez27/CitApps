/// Database table and column name constants.
///
/// Centralizes all Supabase/PostgreSQL table names
/// to prevent typos and facilitate refactoring.
library;

abstract class DbTables {
  static const String barbershops = 'barbershops';
  static const String barbershopHours = 'barbershop_hours';
  static const String profiles = 'profiles';
  static const String clients = 'clients';
  static const String employees = 'employees';
  static const String employeeSchedules = 'employee_schedules';
  static const String employeeDaysOff = 'employee_days_off';
  static const String employeeServices = 'employee_services';
  static const String serviceCategories = 'service_categories';
  static const String services = 'services';
  static const String appointments = 'appointments';
  static const String appointmentServices = 'appointment_services';
  static const String productCategories = 'product_categories';
  static const String products = 'products';
  static const String inventoryMovements = 'inventory_movements';
  static const String sales = 'sales';
  static const String saleItems = 'sale_items';
  static const String payments = 'payments';
  static const String cashRegisters = 'cash_registers';
  static const String cashMovements = 'cash_movements';
}
