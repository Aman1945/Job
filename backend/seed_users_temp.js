const axios = require('axios');

const users = [
    {
        id: "operations@bigsams.in",
        name: "Pranav Varadkar",
        role: "WH Manager",
        location: "Pan India",
        department1: "Store",
        password: "password123"
    },
    {
        id: "logistics.hub@bigsams.in",
        name: "Logistics Hub Manager",
        role: "Logistics",
        location: "Pan India",
        department1: "Logistics",
        password: "password123"
    }
];

const registerUser = async (user) => {
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

const seed = async () => {
    console.log('🌱 Seeding Users...');
    for (const user of users) {
        await registerUser(user);
    }
    console.log('🏁 Seeding Complete.');
};

seed();
