const { HtmlValidate } = require('html-validate');
const path = require('path');

describe('HTML Validation', () => {
  test('index.html should have valid HTML structure', async () => {
    // Custom config - only critical structural errors
    const htmlvalidate = new HtmlValidate({
      extends: ['html-validate:recommended'],
      rules: {
        'void-style': 'off',
        'no-trailing-whitespace': 'off',
        'no-raw-characters': 'off',
        'long-title': 'off',
        'require-sri': 'off',
        'no-inline-style': 'off',
        'tel-non-breaking': 'off',
        'element-required-attributes': 'error',
        'element-permitted-content': 'error',
        'no-unknown-elements': 'error',
        'close-order': 'warn'  // Warn, don't fail on closing tag order
      }
    });
    
    const filePath = path.join(__dirname, '../index.html');
    const report = await htmlvalidate.validateFile(filePath);
    
    // Only fail on severity 2 (errors), not warnings
    const criticalErrors = report.results.flatMap(result => 
      result.messages.filter(msg => msg.severity === 2)
    );
    
    const warnings = report.results.flatMap(result => 
      result.messages.filter(msg => msg.severity === 1)
    );
    
    if (warnings.length > 0) {
      console.log(`\n⚠️  ${warnings.length} HTML warnings (non-critical):`);
      warnings.forEach(msg => {
        console.log(`  Line ${msg.line} - ${msg.message}`);
      });
    }
    
    if (criticalErrors.length > 0) {
      console.log(`\n❌ ${criticalErrors.length} critical HTML errors:`);
      criticalErrors.forEach(msg => {
        console.log(`  Line ${msg.line}:${msg.column} - ${msg.message} (${msg.ruleId})`);
      });
    } else {
      console.log('\n✅ HTML structure is valid - no critical errors!');
    }
    
    expect(criticalErrors.length).toBe(0);
  });
});
