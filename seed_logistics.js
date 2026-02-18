const axios = require('axios');

const user = {
    id: "logistics.hub@bigsams.in",
    name: "Logistics Hub Manager",
    role: "Logistics",
    location: "Pan India",
    department1: "Logistics",
    password: "password123"
};

const registerUser = async () => {
    try {
        await axios.post('http://localhost:3000/api/users', user);
        console.log(`✅ Registered: ${user.id}`);
    } catch (error) {
        if (error.response && error.response.status === 400) {
            console.log(`⚠️  User likely exists: ${user.id}`);
        } else {
            console.error(`❌ Failed to register ${user.id}: ${error.message}`);
        }
    }
};

registerUser();
