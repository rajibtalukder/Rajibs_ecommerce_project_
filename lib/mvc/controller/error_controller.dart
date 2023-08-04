

import '../../service/api/api_exception.dart';
import '../../utils/utils.dart';

class ErrorController {
  void handleApiError(error) {

    switch (error) {
      case BadRequestException:
        Utils.hidePopup();
        Utils.showSnackBar("Error: ${error.errorName}");
        break;
      case ApiNotRespondingException:
        Utils.hidePopup();
        Utils.showSnackBar("Error: ${error.errorName}");
        break;
      // show error dialog
      case ProcessDataException:
        Utils.hidePopup();
        Utils.showSnackBar("Error: ${error.errorName}");
        break;
      // show error dialog
      default:
        Utils.hidePopup();
        Utils.showSnackBar("Error: ${error.errorName}");
        break;
      // show error dialog
    }
  }
}
