/* CSE 536: User-Level Threading Library */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "user/ulthread.h"

/* Standard definitions */
#include <stdbool.h>
#include <stddef.h> 

struct ulthread ulthread[MAXULTHREADS];
struct ulthread *scheduler_thread = &ulthread[0];
struct ulthread *current_thread;

enum ulthread_scheduling_algorithm scheduling_algorithm;

int prev_tid = 0;

/* Get thread ID */
int get_current_tid(void) {
    return current_thread->tid;
}

/* Thread initialization */
void ulthread_init(int schedalgo) {

    struct ulthread *t;
    int i = 0;
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 1 to MAXULTHREADS
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
        t->state = FREE;
        t->tid = i++;
    }
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    scheduler_thread->state = RUNNABLE;
    scheduler_thread->tid = 0;
    // Set the current thread to the scheduler thread
    current_thread = scheduler_thread;

    scheduling_algorithm = schedalgo;
}

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {

    struct ulthread *t;

    // Find a free thread slot and initialize it
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
        if(t->state == FREE){
            t->state = RUNNABLE;
            t->context.ra = start;
            t->context.sp = stack;
            t->context.s0 = args[0];
            t->context.s1 = args[1];
            t->context.s2 = args[2];
            t->context.s3 = args[3];
            t->context.s4 = args[4];
            t->context.s5 = args[5];
            t->ctime = ctime();
            t->priority = priority;
            break;
        }
    }
    if(t == &ulthread[MAXULTHREADS]){
        return false;
    }

    // current_thread = t;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);

    return true;
}

/* Thread scheduler */
void ulthread_schedule(void) {

    current_thread = scheduler_thread;
    struct ulthread *t = 0;
    int flag = 0;

    for(;;){

        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){

            // printf("t->tid: %d\n", t->tid);
            
            if(scheduling_algorithm == 0){
                // Round Robin
                if(t->state != RUNNABLE){
                    continue;
                }
            }
            
            else if(scheduling_algorithm == 1){
                // Priority

                struct ulthread *max_priority_thread = 0;
                struct ulthread *temp = 0;

                if(t->state != RUNNABLE){
                    continue;
                }
                
                max_priority_thread = t;

                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
                        max_priority_thread = temp;
                    }
                }
                if(max_priority_thread != 0){
                    t = max_priority_thread;
                }
            }
            
            else if(scheduling_algorithm == 2){
                // FCFS
                
                struct ulthread *min_ctime = 0;
                struct ulthread *temp = 0;
                if(t->state != RUNNABLE){
                    continue;
                }
                min_ctime = t;
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
                        min_ctime = temp;
                    }
                }
                if(min_ctime != 0){
                    t = min_ctime;
                }
            }
        
            if(t != 0){
                
                current_thread = t;

                flag = 1;

                /* Add this statement to denote which thread-id is being scheduled next */
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());

                // Switch between thread contexts from the scheduler thread to the new thread
                ulthread_context_switch(&scheduler_thread->context, &t->context);

                t = &ulthread[1];
            }
            
        }
        if(flag == 0){
            break;
        }
        else{
            flag = 0;
            struct ulthread *t1 = 0;
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
                if(t1->state == YIELD){
                    t1->state = RUNNABLE;
                }
            }
        }
    }
}

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {

    current_thread->state = YIELD;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid());

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
    
}

/* Destroy thread */
void ulthread_destroy(void) {

    // find the current running thread and mark it as FREE
    current_thread->state = FREE;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid());

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
}
