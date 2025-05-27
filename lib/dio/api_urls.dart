// class ApiUrls {
//   // final url = 'http://192.168.1.100:3000/auth/login'; // For physical device
//   String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator

//   // String baseUrl = 'http://localhost:3000';

//   String login = '/auth/login';
//   String register = '/auth/register';
// }

class ApiUrls {
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // For iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:3000'; // For physical device

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Payment endpoints
  static const String addPayment = '/payments';
  static String paymentById(String id) => '/payments/$id';

  // Member endpoints
  static const String addMember = '/members';
  static String memberById(String id) => '/members/$id';
  static const String getMembers = '/members';

  // Mess endpoints
  static const String mess = '/mess';
  static String messById(String id) => '/mess/$id';

  // Menu endpoints
  static const String menu = '/menu';
  static String menuById(String id) => '/menu/$id';

  // Attendance endpoints
  static const String attendance = '/attendance';
  static String attendanceById(String id) => '/attendance/$id';

  // History endpoints
  static const String history = '/history';
  static const String historySummary = '/history/summary';
  static String historyById(String id) => '/history/$id';

  // Expense endpoints
  static const String addExpenses = '/expenses';
}
