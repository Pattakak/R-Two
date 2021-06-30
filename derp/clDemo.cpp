#include "../include/opencl.hpp"
#include <iostream>
#include <cassert>
#include <numeric>

int main() {
    std::vector<cl::Platform> platforms;
    cl::Platform::get(&platforms);

    assert(platforms.size() > 0);

    auto platform = platforms.front();

    std::vector<cl::Device> devices;
    platforms.front().getDevices(CL_DEVICE_TYPE_GPU, &devices);

    assert(devices.size() > 0);

    auto device = devices.front();
    auto vendor = device.getInfo<CL_DEVICE_VENDOR>();
    auto version = device.getInfo<CL_DEVICE_VERSION>();

    std::cout << "Device Vendor: " << vendor << std::endl;
    std::cout << "Device Version: " << version << std::endl;

    cl::Context context(device);
    cl::Program::Sources sources;

    std::string kernelCode =
        "   void kernel squareArray(global int* input, global int* output) {"
        "       size_t gid = get_global_id(0);"
        "       output[gid] = input[gid] * input[gid];"
        "   }";
    sources.push_back({kernelCode.c_str(), kernelCode.length()});

    cl_int exitcode = 0;

    cl::Program program(context, sources, &exitcode);
    program.build();
    assert(exitcode == CL_SUCCESS);

    cl::Kernel kernel(program, "squareArray", &exitcode);
    assert(exitcode == CL_SUCCESS);

    auto workGroupSize = kernel.getWorkGroupInfo<CL_KERNEL_WORK_GROUP_SIZE>(device);
    std::cout << "Kernel Work Group Size: " << workGroupSize << std::endl;

    std::vector<int> outVec(1024);
    std::vector<int> inVec(1024);
    std::iota(inVec.begin(), inVec.end(), 1);

    cl::Buffer inBuf(context,
                     CL_MEM_READ_ONLY | CL_MEM_HOST_NO_ACCESS | CL_MEM_COPY_HOST_PTR,
                     sizeof(int) * inVec.size(),
                     inVec.data());
    cl::Buffer outBuf(context,
                      CL_MEM_WRITE_ONLY | CL_MEM_HOST_READ_ONLY,
                      sizeof(int) * outVec.size());
    kernel.setArg(0, inBuf);
    kernel.setArg(1, outBuf);

    cl::CommandQueue queue(context, device);

    queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(inVec.size()));
    queue.enqueueReadBuffer(outBuf, CL_TRUE, 0, sizeof(int) * outVec.size(), outVec.data());

    for (std::vector<int>::const_iterator i = outVec.begin(); i != outVec.end(); ++i)
        std::cout << *i << std::endl;

    return 0;
}

