var environment, path, secrets;

path = require('path');

environment = process.env.NODE_ENV || 'development';

path = path.join(process.cwd(), 'secrets', environment + '.json');

try {
  secrets = require(path);
} catch (_error) {
  secrets = {};
}

module.exports = secrets;
