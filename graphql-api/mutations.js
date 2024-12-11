const { GraphQLObjectType, GraphQLString, GraphQLInt } = require('graphql');
const AlumnoType = require('./types/alumno');
const Alumno = require('./models/Alumno');

const Mutation = new GraphQLObjectType({
  name: 'Mutation',
  fields: {
    addAlumno: {
      type: AlumnoType,
      args: {
        name: { type: GraphQLString },
        age: { type: GraphQLInt },
        grade: { type: GraphQLString },
      },
      async resolve(parent, args) {
        const newAlumno = new Alumno({
          name: args.name,
          age: args.age,
          grade: args.grade,
        });
        return await newAlumno.save();
      },
    },
    deleteAlumno: {
      type: AlumnoType,
      args: { id: { type: GraphQLString } },
      async resolve(parent, args) {
        return await Alumno.findByIdAndDelete(args.id);
      },
    },
    updateAlumno: {
      type: AlumnoType,
      args: {
        id: { type: GraphQLString },
        name: { type: GraphQLString },
        age: { type: GraphQLInt },
        grade: { type: GraphQLString },
      },
      async resolve(parent, args) {
        return await Alumno.findByIdAndUpdate(
          args.id,
          {
            $set: {
              name: args.name,
              age: args.age,
              grade: args.grade,
            },
          },
          { new: true }
        );
      },
    },
  },
});

module.exports = Mutation;
