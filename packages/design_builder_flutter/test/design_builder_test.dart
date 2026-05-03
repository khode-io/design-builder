import 'generators/theme_generator_test.dart' as theme_generator_test;
import 'grouper/token_grouper_test.dart' as token_grouper_test;
import 'models/design_token_test.dart' as design_token_test;
import 'models/theme_config_test.dart' as theme_config_test;
import 'models/token_group_test.dart' as token_group_test;
import 'parsers/schema_loader_test.dart' as schema_loader_test;
import 'parsers/token_parser_test.dart' as token_parser_test;
import 'resolvers/alias_resolver_test.dart' as alias_resolver_test;

void main() {
  // Models
  design_token_test.main();
  theme_config_test.main();
  token_group_test.main();

  // Parsers
  schema_loader_test.main();
  token_parser_test.main();

  // Grouper
  token_grouper_test.main();

  // Resolvers
  alias_resolver_test.main();

  // Generators
  theme_generator_test.main();
}
