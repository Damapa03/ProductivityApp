import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/data/black_list_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalBlackListRepository', () {
    test('load devuelve null si aún no hay texto para ese usuario', () async {
      final repo = LocalBlackListRepository();

      expect(await repo.load('ana@flowly.com'), isNull);
    });

    test('guarda y recupera el texto escrito', () async {
      final repo = LocalBlackListRepository();
      const text = 'Comprar pan\nLlamar a Ana\nDeep work 10:00';

      await repo.save('ana@flowly.com', text);

      expect(await repo.load('ana@flowly.com'), text);
    });

    test('los textos quedan aislados por email de usuario', () async {
      final repo = LocalBlackListRepository();

      await repo.save('ana@flowly.com', 'Nota de Ana');
      await repo.save('bob@flowly.com', 'Nota de Bob');

      expect(await repo.load('ana@flowly.com'), 'Nota de Ana');
      expect(await repo.load('bob@flowly.com'), 'Nota de Bob');
    });
  });
}