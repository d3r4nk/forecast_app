import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';
import '../../../core/models/weather_snapshot.dart';
import '../../settings/state/settings_state.dart';

class AiWeatherService {
  OpenAIClient _client() {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      throw Exception('Missing OPENAI_API_KEY in .env');
    }
    return OpenAIClient(apiKey: key.trim());
  }

  String _payload(WeatherSnapshot s, {required double lat, required double lon}) {
    return [
      "Lat: $lat",
      "Lon: $lon",
      "UpdatedAt: ${s.fetchedAt.toIso8601String()}",
      "TempC: ${s.tempC}",
      "MaxTempC(today): ${s.maxTempC}",
      "Humidity%: ${s.humidity}",
      "MaxHumidity%(today): ${s.maxHumidity}",
      "WindSpeed(m/s): ${s.windSpeedMs}",
      "Description: ${s.description}",
    ].join("\n");
  }

  static const String _advisorProtocolVi = """
ACTUAL ACCURACY ONLY:
- Mọi câu trả lời phải dựa trên dữ liệu thời tiết được cung cấp trong yêu cầu (nhiệt độ/độ ẩm/gió/mô tả/thời gian/vị trí).
- Nếu thiếu dữ liệu để kết luận, trả về đúng chuỗi: "Insufficient data to verify".
- Không suy đoán, không điền khoảng trống.

ZERO HALLUCINATION PROTOCOL:
- Không bịa số liệu, ngày giờ, tên địa điểm, cảnh báo, hoặc chi tiết kỹ thuật.
- Nếu mức chắc chắn < 90% cho một nhận định, bỏ nhận định đó hoặc trả "Insufficient data to verify".

PURE INSTRUCTION ADHERENCE:
- Chỉ xuất nội dung theo định dạng đầu ra yêu cầu. Không thêm lời xã giao. Không thêm meta bình luận.

EMOTIONAL NEUTRALITY:
- Văn phong trung tính, mô tả thực tế.

SCOPE:
- Chỉ trả lời liên quan thời tiết/điều kiện ra ngoài trời dựa trên dữ liệu cung cấp.
- Không chẩn đoán y tế. Không đưa khuyến nghị thuốc/điều trị.

LANGUAGE:
- Trả lời bằng tiếng Việt.
""";

  static const String _outputFormatVi = """
ĐẦU RA (không thêm gì khác):
1) TÓM TẮT: 1-2 câu, mô tả chi tiết thời tiết.
2) KHUYẾN NGHỊ: 3-6 gạch đầu dòng, hành động cụ thể.
""";

  static const String _advisorProtocolEn = """
ACTUAL ACCURACY ONLY:
- Every statement must be based strictly on the provided weather data (temperature/humidity/wind/description/time/location).
- If data is insufficient to conclude, output exactly: "Insufficient data to verify".
- No assumptions. Do not fill gaps.

ZERO HALLUCINATION PROTOCOL:
- Do not invent numbers, timestamps, place names, warnings, or technical details.
- If confidence is < 90% for a claim, omit it or output "Insufficient data to verify".

PURE INSTRUCTION ADHERENCE:
- Output only in the required format. No pleasantries. No meta commentary.

EMOTIONAL NEUTRALITY:
- Neutral, factual tone.

SCOPE:
- Only weather/outdoor-condition advice based on provided data.
- No medical diagnosis. No medication/treatment advice.

LANGUAGE:
- Respond in English.
""";

  static const String _outputFormatEn = """
OUTPUT (nothing else):
1) SUMMARY: 1–2 sentences describing the weather in detail.
2) RECOMMENDATIONS: 3–6 bullet points with concrete actions.
""";

  Future<String> getAdvice({
    required WeatherSnapshot snapshot,
    required double lat,
    required double lon,
    required SettingsState settings,
  }) async {
    final client = _client();

    final isEn = settings.isEnglish;

    final devText = [
      isEn ? _advisorProtocolEn.trim() : _advisorProtocolVi.trim(),
      isEn ? _outputFormatEn.trim() : _outputFormatVi.trim(),
    ].join("\n\n");

    final userText = isEn
        ? [
      "TASK: Analyze the weather and provide practical advice.",
      "",
      "WEATHER DATA:",
      _payload(snapshot, lat: lat, lon: lon),
    ].join("\n")
        : [
      "NHIỆM VỤ: Phân tích thời tiết và đưa lời khuyên.",
      "",
      "DỮ LIỆU THỜI TIẾT:",
      _payload(snapshot, lat: lat, lon: lon),
    ].join("\n");

    final res = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId('gpt-4o-mini'),
        messages: [
          ChatCompletionMessage.developer(
            content: ChatCompletionDeveloperMessageContent.text(devText),
          ),
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(userText),
          ),
        ],
      ),
    );

    return res.choices.first.message.content ?? "";
  }
}
