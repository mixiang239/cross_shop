import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(engine: FlutterEngine): void {
    super.configureFlutterEngine(engine);
    GeneratedPluginRegistrant.registerWith(engine);
  }
}
