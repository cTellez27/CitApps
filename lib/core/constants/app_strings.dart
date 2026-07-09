/// Static string constants used across the app.
library;

abstract class AppStrings {
  // ── App ──
  static const String appName = 'CitApps';
  static const String appTagline = 'Tu barbería, bajo control.';

  // ── Auth ──
  static const String login = 'Iniciar sesión';
  static const String register = 'Crear cuenta';
  static const String logout = 'Cerrar sesión';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String resetPassword = 'Restablecer contraseña';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String fullName = 'Nombre completo';
  static const String phone = 'Teléfono';

  // ── Navigation ──
  static const String dashboard = 'Inicio';
  static const String clients = 'Clientes';
  static const String employees = 'Empleados';
  static const String services = 'Servicios';
  static const String schedule = 'Agenda';
  static const String inventory = 'Inventario';
  static const String sales = 'Ventas';
  static const String cashRegister = 'Caja';
  static const String reports = 'Reportes';
  static const String settings = 'Configuración';
  static const String more = 'Más';

  // ── Common Actions ──
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String create = 'Crear';
  static const String search = 'Buscar';
  static const String filter = 'Filtrar';
  static const String retry = 'Reintentar';
  static const String confirm = 'Confirmar';
  static const String close = 'Cerrar';
  static const String add = 'Agregar';
  static const String back = 'Volver';

  // ── Status ──
  static const String active = 'Activo';
  static const String inactive = 'Inactivo';

  // ── Appointment Status ──
  static const String pending = 'Pendiente';
  static const String confirmed = 'Confirmada';
  static const String inProgress = 'En proceso';
  static const String completed = 'Completada';
  static const String cancelled = 'Cancelada';
  static const String noShow = 'No asistió';

  // ── Roles ──
  static const String owner = 'Dueño';
  static const String admin = 'Administrador';
  static const String barber = 'Barbero';
  static const String receptionist = 'Recepcionista';

  // ── Errors ──
  static const String genericError = 'Ocurrió un error. Intenta de nuevo.';
  static const String noConnection = 'Sin conexión a internet.';
  static const String sessionExpired = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
  static const String unauthorized = 'No tienes permisos para esta acción.';

  // ── Empty States ──
  static const String noClients = 'Aún no tienes clientes registrados.';
  static const String noAppointments = 'No hay citas programadas.';
  static const String noSales = 'No hay ventas registradas.';
  static const String noProducts = 'No hay productos en inventario.';
  static const String noResults = 'Sin resultados.';
}
