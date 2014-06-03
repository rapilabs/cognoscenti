/*
 * Copyright 2013 Keith D Swenson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors Include: Shamim Quader, Sameer Pradhan, Kumar Raja, Jim Farris,
 * Sandia Yang, CY Chen, Rajiv Onat, Neal Wang, Dennis Tam, Shikha Srivastava,
 * Anamika Chaudhari, Ajay Kakkar, Rajeev Rastogi
 */

package org.socialbiz.cog;

import java.util.Vector;
import java.util.Hashtable;

/**
* This is a Least Recently Used Cache.
* Believe it or not, Java does not come with such a simple thing.
* This keeps up to N object referenced by key, kicking out the oldest
* one when the new one is added.
* Everythign is a Java Object -- no typing
*/
public class LRUCache
{
    private Vector<Object>    vec;
    private Hashtable<String,Object> hash;
    private int       cacheSize;

    public LRUCache(int numberToCache)
    {
        cacheSize = numberToCache;
        emptyCache();
    }

    public synchronized void emptyCache()
    {
        vec = new Vector<Object>(cacheSize);
        hash = new Hashtable<String,Object>(cacheSize);
    }

    /**
    * Get an object out of the cache.
    * NOTE: the object is removed from the cache so that the
    * thread that takes it has exclusive access to the object
    * but remember, when done, store it back in there.
    *
    * If two thread are trying to manipulate the same object
    * at a time, they will end up each having a separate copy
    * of the object.  This design is *no worse* than without the cache.
    * If you have a file, and multiple threads are reading and
    * updating the file, then it is possible for multiple threads
    * to have the contents of one file in memory in two places,and
    * to be updating that file multiple times, writing on each other.
    * When the cache is used, the first thread will get the cached
    * object, and the second thread will not find one in the cache,
    * and so will go read the file.  Then one will store the object
    * and when the second stores the object, the first will be
    * replaced, and you will still have only one in the cache.
    *
    * The only real solution is to implement a "page lock" mechanism
    * where a thread gets a lock on a page id, and then releases it
    * when done, forcing reads and updates to be serialized.  This
    * mechanism is needed whether you have a cache or not.
    * So, the cache has no effect on this, but the cache DOES
    * make the first thread to request the page much much faster
    * and this reduces the posibility of simulataneous access.
    */
    public synchronized Object recall(String id)
    {
        Object o = hash.get(id);
        if (o!=null)
        {
            vec.remove(o);
            hash.remove(o);
        }
        return o;
    }

    /**
    * This is a sloppy form of recall that gets the object without removing
    * it and can be used in cases where the code is not written to store
    * the object back in the cache.  Using recallQuick gives an object
    * but it might be shared by multiple thread and might be changed by
    * another thread while this thread is using it.
    *
    * This should be avoided, but proper implementation of the regular
    * cache implementation means a big redesign of the code to clean up
    * the page objects.  Don't have time now, so implement this quick
    * and dirty version for now.
    */
    public synchronized Object recallQuick(String id)
    {
        Object o = hash.get(id);
        return o;
    }

    /**
    * Put an object (back) into the cache associated with the id.
    * If the cache is full, remove the oldest objects from cache.
    * If an object already exists with that id, then this new object
    * will replace it.
    */
    public synchronized void store(String id, Object o)
    {
        Object prev = hash.get(id);
        if (prev!=null)
        {
            vec.remove(prev);
            hash.remove(prev);
        }
        else
        {
            //then, if cache full, remove the oldest ones
            while (vec.size()>=cacheSize)
            {
                prev = vec.remove(cacheSize-1);
                hash.remove(prev);
            }
        }
        vec.insertElementAt(o, 0);
        hash.put(id, o);
    }

}