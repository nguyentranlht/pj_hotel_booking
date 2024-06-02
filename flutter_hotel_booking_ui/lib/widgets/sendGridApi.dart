import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendConfirmationEmail(String email, String firstname, String hotelName, String roomNumber, String startDate, String endDate, String totalAmount) async {

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'personalizations': [
        {
          'to': [
            {'email': email}
          ],
          'subject': 'Xác nhận đơn hàng'
        }
      ],
      'from': {'email': 'kocogidat@gmail.com'},
      'content': [
        {
          'type': 'text/plain',
          'value': 'Xin chào $firstname,\n\nCảm ơn bạn đã đặt phòng khách sạn "$hotelName" tại ứng dụng. Chúng tôi rất vui mừng được phục vụ bạn!\n\nThông tin đơn hàng của bạn:\n- Số phòng: $roomNumber\n- Ngày bắt đầu: $startDate\n- Ngày kết thúc: $endDate\n- Tổng số tiền: $totalAmount\n\nChúng tôi mong bạn sẽ có một kỳ nghỉ tuyệt vời tại khách sạn. Hãy liên hệ với chúng tôi nếu bạn có bất kỳ câu hỏi nào khác. Xin cảm ơn và chúc bạn một ngày tốt lành!'
        }
      ]
    }),
  );

  if (response.statusCode == 202) {
    print('Email sent!');
  } else {
    print('Failed to send email: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
