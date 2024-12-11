const express = require('express');
const { graphqlHTTP } = require('express-graphql');
const mongoose = require('mongoose');
const cors = require('cors');
const schema = require('./schema'); // Asegúrate de tener el esquema de GraphQL

const app = express();

// Habilitar CORS
app.use(cors()); // Permite todas las solicitudes de cualquier origen
// Si deseas restringir el origen, puedes hacer algo como:
// app.use(cors({ origin: 'http://localhost:35167' }));

// Conexión a MongoDB
mongoose.connect('linea-de-conexion', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

mongoose.connection.once('open', () => {
  console.log('Conectado a la base de datos MongoDB');
});

// Configurar el endpoint de GraphQL
app.use(
  '/graphql',
  graphqlHTTP({
    schema,
    graphiql: true, // Habilitar la interfaz de GraphiQL para pruebas
  })
);

// Configurar puerto
const PORT = 25577;
app.listen(PORT, () => {
  console.log(`Servidor GraphQL ejecutándose en http://localhost:${PORT}/graphql`);
});
