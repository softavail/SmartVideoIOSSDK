//
//  VDEEventListener.h
//  VideoEngager
//
//  Created by Angel Terziev on 2.01.18.
//  Copyright © 2018 VideoEngager. All rights reserved.
//

#ifndef VDEEventListener_h
#define VDEEventListener_h

// This is needed or else a warning is thrown with the performSelector call.
// Placing it here to only avoid warnings in this file as it is expected.
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

template <class T, class Event>
class VDEEventListener : public instac::IEventSink<Event>
{
public:
    VDEEventListener(T* _object, SEL _method) :
    m_object(_object),
    m_method(_method)
    {
    }
    
    void onEvent(const Event & event)
    {
        NSValue * obj = [NSValue valueWithPointer:&event];
        [m_object performSelector:m_method withObject:obj];
    }
    
private:
    SEL m_method;
    T* __weak m_object;
};

#endif /* VDEEventListener_h */
