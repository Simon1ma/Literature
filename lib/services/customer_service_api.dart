/// 客服API占位：不接入真实AI，仅返回固定文案。
class CustomerServiceApi {
  Future<String> getReply(String userInput) async {
    // 在未来可替换为真实的AI接口调用。
    await Future.delayed(const Duration(milliseconds: 300));
    return '未接入API，当前暂不可用';
  }
}
