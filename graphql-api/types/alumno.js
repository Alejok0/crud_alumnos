const { GraphQLObjectType, GraphQLID, GraphQLString, GraphQLInt } = require('graphql');

const AlumnoType = new GraphQLObjectType({
  name: 'Alumno',
  fields: {
    id: { type: GraphQLID },
    name: { type: GraphQLString },
    age: { type: GraphQLInt },
    grade: { type: GraphQLString },
  },
});

module.exports = AlumnoType;
