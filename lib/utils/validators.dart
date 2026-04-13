class AppValidators{

  //Check null/empty
  static String? required(String? value){
    if(value == null || value.isEmpty)
      return 'This field is required';
    return null;
  }

  //Check number
  static String? number(String? value){
    if(value == null || value.isEmpty)
      return 'required';
    if(double.tryParse(value)==null)
      return 'Enter a valid number';
    return null;
  }

  //Check url
  static String? url(String? value){
    if(!isRawUrlValid(value))
      return 'Enter a valid image URL';
    return null;
  }

  static bool isRawUrlValid(String? url){
    if(url==null || url.isEmpty)
      return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && (uri.isScheme('http') || uri.isScheme('https'));
  }
}