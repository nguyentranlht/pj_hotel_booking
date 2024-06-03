import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendConfirmationEmailCancel(String email, String firstname, String hotelName, String roomNumber, String startDate, String endDate, String totalAmount) async {

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
          'subject': 'Xác nhận hủy đơn hàng'
        }
      ],
      'from': {'email': 'kocogidat@gmail.com'},
      'content': [
        {
          'type': 'text/plain',
          'value': 'Xin chào $firstname,\n\nChúng tôi xin thông báo rằng đơn hàng của bạn tại khách sạn "$hotelName" đã được hủy thành công. Dưới đây là thông tin chi tiết:\n- Số phòng: $roomNumber\n- Ngày bắt đầu: $startDate\n- Ngày kết thúc: $endDate\n- Tổng số tiền: $totalAmount\n\nChúng tôi rất tiếc về sự bất tiện này và hy vọng bạn sẽ quay lại với chúng tôi trong tương lai. Nếu có bất kỳ câu hỏi hoặc thắc mắc nào, vui lòng liên hệ với chúng tôi. Xin cảm ơn và chúc bạn một ngày tốt lành!'
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
