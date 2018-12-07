#include <iostream>
#include <fstream>
#include <cmath>
#include <iomanip>
#include <string>
#include <valarray>
#include "ConfigFile.tpp" // Fichier .tpp car inclut un template

using namespace std;

typedef valarray<double> dArray;

double square (double x) {return x*x;}

class Exercice4{

private:

  //Simulation parameters
  int sampling, last;
  double tFin;

  //Physical parameters

  size_t d; //dimension
  size_t N; //number of bodies
  double G,rho,Cx,S;


  void printOut(bool force)
  {
    if((!force && last>=sampling) || (force && last!=1))
    {
      affiche();
      last = 1;
    }
    else
    {
      last++;
    }
  }

  virtual void affiche() = 0;

  dArray Fgrav(size_t i, size_t j, const dArray& y){
    dArray distance(y[slice(d*i,  d, 1)] - y[slice(d*j,  d, 1)]) ;
    dArray distSquare(distance.apply(square));
    double normD(sqrt(distSquare.sum()));
    return -G * M[i] * M[j] / pow(normD,3) * distance;
  }

  dArray Fdrag(size_t i, size_t j, const dArray& y){

    dArray distance(y[slice(d * i, d, 1)] - y[slice(d * j, d, 1)]);
    dArray distSquare(distance.apply(square));
    double normD(sqrt(distSquare.sum()));

    dArray relVel(y[slice(d * i + N*d, d, 1)] - y[slice(d * j+N*d,  d, 1)]);
    dArray relVelSquare(relVel.apply(square));
    double normV(sqrt(relVelSquare.sum()));

    return -0.5 * rho * S * Cx * normD * normV * relVel;
  }

  virtual void step() = 0;

protected:
    double dt;
    double t;
    dArray Y;//position and velocity
    dArray M;
    dArray R;

    double nSteps;

    ofstream *outputFile;

    dArray f(const dArray& y, double t){
      dArray dy(y);
      dy[slice(0,N*d,1)] = y[slice(N*d,N*d,1)];


      for(size_t i(0); i<N; ++i){
        valarray<double> tot(d);
        for(size_t j(0); j<N; ++j){
          if(i!=j){
            tot +=  Fgrav(i, j, y);
          }
        }
        tot /= M[i];
        dy[slice(d * i + N * d, d, 1)] = tot;

      }
      return dy;
    }

    dArray RK4(const dArray& yi, double ti, double dt)
    {
      dArray k1(dt * f(yi, ti));
      dArray k2(dt * f(yi+0.5*k1, ti+0.5*dt));
      dArray k3(dt * f(yi+0.5*k2, ti+0.5*dt));
      dArray k4(dt * f(yi+k3, ti+dt));
      return yi + 1/6.0*(k1+2.0*k2+2.0*k3+k4);
    }



  public:
    Exercice4(ConfigFile configFile)
    {

      tFin     = configFile.get<double>("tFin");
      nSteps   = configFile.get<int>("nSteps");
      dt       = tFin/nSteps;
      sampling = configFile.get<unsigned int>("sampling");
      N        = configFile.get<size_t>("N");
      d        = configFile.get<size_t>("d");
      G        = configFile.get<double>("G");
      rho      = configFile.get<double>("rho");
      Cx       = configFile.get<double>("Cx");
      S        = configFile.get<double>("S");

      Y = dArray(2*N*d);
      M = dArray(N);
      R = dArray(N);


      for(size_t i(0); i < N;++i){
        for(size_t j(0); j < d;++j){
          string key("x" + to_string(j + 1) + "_" + to_string(i + 1)); //Convention xj_i
          Y[i * d + j] = configFile.get<double>(key);
        }
      }

      for (size_t i(0); i < N; ++i){
        for (size_t j(0); j < d; ++j){
          string key("v" + to_string(j + 1) + "_" + to_string(i + 1)); //Convention vj_i
          Y[i * d + j+N*d] = configFile.get<double>(key);
        }
      }

      for (size_t i(0); i < N; ++i){
        string key("m_" + to_string(i + 1)); //Convention m_i
        M[i] = configFile.get<double>(key);
      }


      for (size_t i(0); i < N; ++i){
        string key("r_" + to_string(i + 1)); //Convention r_i
        R[i] = configFile.get<double>(key);
      }


      // Ouverture du fichier de sortie
      outputFile = new ofstream(configFile.get<string>("output").c_str());
      outputFile->precision(15);
  };

  virtual ~Exercice4()
  {
    outputFile->close();
    delete outputFile;
  };

  void run()
  {
    t = 0.;
    last = 0;
    printOut(true);

    while( t < tFin-0.5*dt )
    {
      step();
      t += dt;
      printOut(false);
    }
    printOut(true);
  };

};

class Ex4Fixed : public Exercice4
{
public:
  Ex4Fixed(ConfigFile configFile) : Exercice4(configFile) {}

  void affiche(){
    *outputFile << t << " ";
    for (auto &el : Y)
    {
      *outputFile << el << " ";
    }
    *outputFile << endl;
  }

  void step(){
    Y=RK4(Y,t,dt);
  }
};

class Ex4Adapt : public Exercice4
{
public:
  Ex4Adapt(ConfigFile configFile) : Exercice4(configFile) {
    e = configFile.get<double>("e");
    c = 0;
  }

  double e;

  dArray Y1;
  dArray Y2;
  dArray Y_;
  double d;
  bool c;

      void step()
  {
    AdaptDt();
  }

  void affiche()
  {
    *outputFile << t << " ";
    for (auto &el : Y)
    {
      *outputFile << el << " ";
    }
    *outputFile << dt << " " << d <<" " << c << endl;
  }

  void AdaptDt(){
    dArray Y1(RK4(Y, t, dt));
    dArray Y2(RK4(Y, t, dt*0.5));
    dArray Y_(RK4(Y2, t+dt*0.5, dt*0.5));

    Y2 = Y_ - Y1;
    Y2 = abs(Y2);
    d = Y2.max();

    if (d >= e){
      dt *= 0.98 * pow((e / d), 1.0 / 5.0);
      //++c;
      AdaptDt();
    }else {
      dt *= pow((e/d),1.0/5.0);
      //dt = min(dt, tFin-dt);
      Y = Y_;

    }
  }
};

int main(int argc, char *argv[])
{
  string inputPath("configuration.in"); // Fichier d'input par defaut
  if (argc > 1)                         // Fichier d'input specifie par l'utilisateur 
    inputPath = argv[1];

  ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

  for (int i(2); i < argc; ++i)
    configFile.process(argv[i]);

  string dtType(configFile.get<string>("schema"));

  Exercice4 *ex4;
  if (dtType == "Adaptive" || dtType == "A")
  {
    ex4 = new Ex4Adapt(configFile);
  }
  else if (dtType == "Fixed" || dtType == "F")
  {
    ex4 = new Ex4Fixed(configFile);
  }
  else
  {
    cerr << "Schema inconnu" << endl;
    return -1;
  }

  ex4->run();

  delete ex4;
  cout << "Fin de la simulation." << endl;
  return 0;
}
