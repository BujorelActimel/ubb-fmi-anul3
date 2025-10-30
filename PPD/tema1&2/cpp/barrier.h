#ifndef BARRIER_H
#define BARRIER_H

#include <mutex>
#include <condition_variable>

class Barrier {
private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::size_t count_;
    std::size_t threshold_;
    std::size_t generation_;

public:
    explicit Barrier(std::size_t count)
        : count_(count), threshold_(count), generation_(0) {}

    void arrive_and_wait() {
        std::unique_lock<std::mutex> lock(mutex_);
        auto gen = generation_;

        if (--count_ == 0) {
            generation_++;
            count_ = threshold_;
            cv_.notify_all();
        } else {
            cv_.wait(lock, [this, gen] { return gen != generation_; });
        }
    }
};

#endif // BARRIER_H
