class ApiUrls {
  // final url = 'http://192.168.1.100:3000/auth/login'; // For physical device
  // String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator

  String baseUrl = 'http://localhost:3000';

  String login = '/auth/login';
  String register = '/auth/register';
  String addMember = '/members';
  String getMembers = '/members';
  String updateMember = '/members';
  String deleteMember = '/members';
  String addPayment = '/payments';
  String addExpanse = '/expenses';
  String getExpanse = '/expenses';
  String updateExpanse = '/expense';
  String deleteExpanse = '/expense';
}
