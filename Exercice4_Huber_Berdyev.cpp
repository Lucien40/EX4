#include <iostream>
#include <fstream>
#include <cmath>
#include <iomanip>
#include <string>
#include <valarray>
#include "ConfigFile.tpp" // Fichier .tpp car inclut un template

using namespace std;

typedef valarray<long double> dArray;

long double square(long double x) { return x * x; }

long double norm(dArray const &x)
{
  long double s(0);
  for (auto el : x)
  {
    s += el * el;
  }
  return sqrt(s);
}

class Exercice4
{

private:
  //Simulation parameters
  int sampling, last;

  //Physical parameters

  size_t d; //dimension
  long double G;

  void printOut(bool force)
  {
    if ((!force && last >= sampling) || (force && last != 1))
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

  long double relVel(size_t i, size_t j, const dArray &y)
  {
    dArray relVel(y[slice(d * i + N * d, d, 1)] - y[slice(d * j + N * d, d, 1)]);
    dArray relVelSquare(relVel.apply(square));
    return (sqrt(relVelSquare.sum()));
  }


  dArray pnc(const dArray &y)
  {
    dArray Pnc(N);
    for (size_t i(0); i < N; ++i)
    {
      long double pnci(0.0);
      for (size_t j(0); j < N; ++j)
      {
        if (i != j)
        {
          dArray fd(Fdrag(i, j, y));
          for (size_t k(0); k < d; ++k)
          {
            pnci += y[d * i + N * d + k] + fd[k];
          }
        }
      }
      Pnc[i] = pnci;
    }
    return Pnc;
  }

  dArray Fgrav(size_t i, size_t j, const dArray &y)
  {
    dArray distance(y[slice(d * i, d, 1)] - y[slice(d * j, d, 1)]);
    long double normD(norm(distance));
    return -G * M[i] * M[j] / pow(normD, 3.0) * distance;
  }

  dArray Fdrag(size_t body, size_t other, const dArray &y)
  {

    //Fdrag of other on body
    long double normD(dist(body, other, y));

    dArray relVel(y[slice(d * body + N * d, d, 1)] - y[slice(d * other + N * d, d, 1)]);

    long double normV(norm(relVel));

    return -0.5L * rho(normD, other) * S[body] * Cx[body] * normV * relVel;
  }

  long double rho(long double dist, size_t i)
  {
    if (Rho[i] == 0)
      return 0;
    else
      return Rho[i] * exp(-(dist - R[i]) / Lambda[i]);
  }

  virtual void step() = 0;

protected:
  long double dt;

  size_t N; //number of bodies
  long double t;
  dArray Pnc;
  dArray Y; //position and velocity
  dArray M;
  dArray R;
  dArray Rho;
  dArray Cx;
  dArray S;
  dArray Lambda;

  long double tFin;

  long double nSteps;

  ofstream *outputFile;
  long double potGrav(size_t i, size_t j, const dArray &y)
  {
    long double normD(dist(i, j, y));
    return -G * M[i] * M[j] / normD;
  }

  long double kinEng(size_t i, const dArray &y)
  {
    dArray Vel(y[slice(d * i + N * d, d, 1)]);
    long double normV(norm(Vel));
    return M[i] * normV * normV * 0.5L;
  }

  dArray a(size_t body, const dArray &y)
  {

    long double z(0);

    dArray acc(z, d);

    for (size_t other(0); other < N; ++other)
    {
      if (body != other)
      {
        acc += Fgrav(body, other, y) + Fdrag(body, other, y);
      }
    }
    acc /= M[body];
    return acc;
  }

  long double dist(size_t i, size_t j, const dArray &y)
  {
    dArray distance(y[slice(d * i, d, 1)] - y[slice(d * j, d, 1)]);
    return (norm(distance));
  }

  dArray f(const dArray &y, long double t)
  {
    dArray dy(y);

    dy[slice(0, N * d, 1)] = y[slice(N * d, N * d, 1)];

    for (size_t i(0); i < N; ++i)
    {

      dy[slice(d * i + N * d, d, 1)] = a(i, y);
    }
    return dy;
  }

  dArray RK4(const dArray &yi, long double ti, long double dt)
  {
    dArray k1(dt * f(yi, ti));
    dArray k2(dt * f(yi + 0.5L * k1, ti + 0.5L * dt));
    dArray k3(dt * f(yi + 0.5L * k2, ti + 0.5L * dt));
    dArray k4(dt * f(yi + k3, ti + dt));
    return yi + 1.0L / 6.0L * (k1 + 2.0L * k2 + 2.0L * k3 + k4);
  }

  long double energyTot()
  {
    long double potSum(0);
    long double kinSum(0);

    for (size_t i = 0; i < N; ++i)
    {
      for (size_t j = 0; j < N; ++j)
      {
        if (i != j)
          potSum += potGrav(i, j, Y);
      }
      kinSum += kinEng(i, Y);
    }
    return kinSum + potSum * 0.5L;
  }

public:
  Exercice4(ConfigFile configFile)
  {

    tFin = configFile.get<long double>("tFin");
    nSteps = configFile.get<int>("nSteps");
    dt = tFin / nSteps;

    sampling = configFile.get<unsigned int>("sampling");
    N = configFile.get<size_t>("N");
    d = configFile.get<size_t>("d");
    G = configFile.get<long double>("G");

    Y = dArray(2 * N * d);
    M = dArray(N);
    R = dArray(N);
    Rho = dArray(N);
    Cx = dArray(N);
    S = dArray(N);
    Lambda = dArray(N);

    for (size_t i(0); i < N; ++i)
    {
      for (size_t j(0); j < d; ++j)
      {
        string key("x" + to_string(j + 1) + "_" + to_string(i + 1)); //Convention xj_i
        Y[i * d + j] = configFile.get<long double>(key);

        key = ("v" + to_string(j + 1) + "_" + to_string(i + 1)); //Convention vj_i
        Y[i * d + j + N * d] = configFile.get<long double>(key);
      }
    }

    for (size_t i(0); i < N; ++i)
    {
      string key("m_" + to_string(i + 1)); //Convention m_i
      M[i] = configFile.get<long double>(key);

      key = ("r_" + to_string(i + 1)); //Convention r_i
      R[i] = configFile.get<long double>(key);

      key = ("rho_" + to_string(i + 1)); //Convention rho_i
      Rho[i] = configFile.get<long double>(key);

      if (Rho[i] != 0)
      {
        key = ("lambda_" + to_string(i + 1)); //Convention lambda_i
        Lambda[i] = configFile.get<long double>(key);
      }
      else
      {
        Lambda[i] = 1.0L;
      }

      key = ("Cx_" + to_string(i + 1)); //Convention Cx_i
      Cx[i] = configFile.get<long double>(key);

      if (Cx[i] != 0)
      {
        key = ("S_" + to_string(i + 1)); //Convention S_i
        S[i] = configFile.get<long double>(key);
      }
      else
      {
        S[i] = 0.0L;
      }
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
    Pnc = pnc(Y);
    printOut(true);

    while (t < tFin - 0.5L * dt)
    {
      Pnc = pnc(Y);
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

  void affiche()
  {
    *outputFile << t << " ";
    for (auto &el : Y)
    {
      *outputFile << el << " ";
    }
    *outputFile << energyTot() << " ";
    for (size_t i(0); i < N; ++i)
    {
      *outputFile << norm(a(i, Y)) << " ";
    }

    for (size_t i(0); i < N; ++i)
    {
      *outputFile << Pnc[i] << " ";
    }
    *outputFile << endl;
  }

  void step()
  {
    Y = RK4(Y, t, dt);
  }
};

class Ex4Adapt : public Exercice4
{
public:
  long double e;

  dArray Y1;
  dArray Y2;
  dArray Y_;
  long double d;
  bool c;

  Ex4Adapt(ConfigFile configFile) : Exercice4(configFile)
  {
    e = configFile.get<long double>("e");
    c = 0;
  }

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
    *outputFile << energyTot() << " ";
    for (size_t i(0); i < N; ++i)
    {
      *outputFile << norm(a(i, Y)) << " ";
    }

    for (size_t i(0); i < N; ++i)
    {
      *outputFile << Pnc[i] << " ";
    }
    *outputFile << dt << " " << endl;
  }

  void AdaptDt()
  {
    dArray Y1(RK4(Y, t, dt));
    dArray Y2(RK4(Y, t, dt * 0.5L));
    dArray Y_(RK4(Y2, t + dt * 0.5L, dt * 0.5L));

    Y2 = Y_ - Y1;
    Y2 = abs(Y2);
    d = Y2.max();

    if (d >= e)
    {
      dt *= 0.98L * pow((e / d), 1.0L / 5.0L);
      //++c;
      AdaptDt();
    }
    else
    {
      dt *= pow((e / d), 1.0L / 5.0L);
      dt = min(dt, tFin - t);
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
