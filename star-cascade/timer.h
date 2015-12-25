#ifndef _TIMER_H_
#define _TIMER_H_

#include <string>
#include <sstream>
#include <timer.h>// This is in windows
#include <time.h>
#include <windows.h> 


//#include <sys/time.h> //This is not in Windows, needs change
//All timevals in code fail due to this unsupported include

using namespace std;

//A class called timer is created
class timer {
public:
  timer(string timer_name) {
    name = timer_name;
    total_time = 0;
    calls = 0;
  };

  ~timer() {}; //destructor- kill the variable on the memory- local scope

  void tic() {
    SYSTEMTIME tv;
    //struct timeval tv; //Timeval- method of storing time data doesn't work without sys/time.h
    //gettimeofday(&tv, NULL); //gettimeofday is not in windows- it gets the year, date, time, so on. I thought perhaps we could use clock and make this relative?
    GetSystemTime(&tv);
    ///last_time = (double)tv.tv_sec + 1e-6*(double)tv.tv_usec; //last time is created by adding the normal and micro(?) seconds together to get last_time
    last_time = (double)tv.wSecond + 1e-3*(double)tv.wMilliseconds;
    calls++; //calls becomes 1 more, calls starts as 0 as shown above
  };

  void toc() {
   SYSTEMTIME tv;
// struct timeval tv; //Timeval here
    //gettimeofday(&tv, NULL);
    //double cur_time = (double)tv.tv_sec + 1e-6*(double)tv.tv_usec; 
   double cur_time = (double)tv.wSecond + 1e-6*(double)tv.wMilliseconds;
    total_time += cur_time - last_time; //finds the total time it took between tic and toc
  };

  const char *msg() { //sets up a pointer called msg
    ostringstream oss;
    oss << "timer '" << name 
        << "' = " << total_time << " sec in " 
        << calls << " call(s)";
    return oss.str().c_str();
  };

  void mexPrintTimer() {
    mexPrintf("timer '%s' = %f sec in %d call(s)\n", name.c_str(), total_time, calls);
  };

  double getTotalTime() {
    return total_time; //total time is defined in void toc
  };

private: //These values can only be used by the functions in this class
  string name;
  int calls;
  double last_time;
  double total_time;
};

#endif
