const dateStr = new Date().toLocaleDateString('en-US', { month: 'short', year: '2-digit' });
console.log('Original Date:', dateStr);
console.log('Formatted Month:', dateStr.replace(' ', "'"));
