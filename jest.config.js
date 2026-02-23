module.exports = {
  testMatch: ['**/tests/**/*.test.js'],
  modulePathIgnorePatterns: ['<rootDir>/lambda/', '<rootDir>/lambda-booking/node_modules/'],
  collectCoverageFrom: ['tests/**/*.js']
};
