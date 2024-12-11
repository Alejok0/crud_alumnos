const { GraphQLObjectType, GraphQLList, GraphQLID } = require('graphql');
const AlumnoType = require('./types/alumno');
const Alumno = require('./models/Alumno');

const RootQuery = new GraphQLObjectType({
  name: 'RootQueryType',
  fields: {
    alumnos: {
      type: new GraphQLList(AlumnoType),
      async resolve() {
        return await Alumno.find();
      },
    },
    alumno: {
      type: AlumnoType,
      args: { id: { type: GraphQLID } },
      async resolve(parent, args) {
        return await Alumno.findById(args.id);
      },
    },
  },
});

module.exports = RootQuery;
