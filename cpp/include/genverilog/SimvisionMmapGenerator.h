/**
 * SimvisionMmapGenerator.h
 *
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send 
 * a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.  
 *
 */

#ifndef SIMVISIONMMAPGENERATOR_H_
#define SIMVISIONMMAPGENERATOR_H_

// Includes
//-----------------

//-- Std
#include <string>
using namespace std;

//-- Qt
#include <QtCore>

//-- Generator
#include<generate/Generator.h>
#include<generate/GeneratorBuilder.h>

class SimvisionMmapGenerator: public Generator, public GeneratorBuilder {
    public:
        SimvisionMmapGenerator();
        virtual ~SimvisionMmapGenerator();

        /** \defgroup Builder Builder Methods */
        /** @{ */

        virtual Generator * newInstance();

        /** @} */

        /** \defgroup Generator Generator Methods */
        /** @{ */

        /**
         * Returns a short name of this Generator
         * @return
         */
        virtual QString getName();

        /**
         * Returns a short description of this Generator
         * @return
         */
        virtual QString getDescription();

        /**
         * Do the actual generation
         * @param fsm
         * @param dataStream
         */
        virtual void generate(Fsm * fsm,QDataStream * dataStream);


        /** @} */


};

#endif /* SIMVISIONMMAPGENERATOR_H_ */
