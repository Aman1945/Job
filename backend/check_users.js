const axios = require('axios');

const check = async () => {
    try {
        const res = await axios.get('http://localhost:3000/api/users');
        console.log('✅ Users found:', res.data.length);
        const ops = res.data.find(u => u.id === 'operations@bigsams.in' || u.email === 'operations@bigsams.in');
        const logHub = res.data.find(u => u.id === 'logistics.hub@bigsams.in' || u.email === 'logistics.hub@bigsams.in');

        console.log('Operations User:', ops ? 'FOUND' : 'MISSING');
        console.log('Logistics Hub User:', logHub ? 'FOUND' : 'MISSING');

        if (ops) console.log(JSON.stringify(ops, null, 2));

    } catch (error) {
        console.error('❌ Error fetching users:', error.message);
    }
};

check();
