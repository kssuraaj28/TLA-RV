#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Pass.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Transforms/IPO/PassManagerBuilder.h>
using namespace llvm;

namespace {
struct Instrumentor : public FunctionPass {
  static char ID;
  Instrumentor() : FunctionPass(ID) {}

  virtual bool runOnFunction(Function &F) {

    LLVMContext &Ctx = F.getContext();
    FunctionCallee logPart = F.getParent()->getOrInsertFunction(
        "log_into_state", Type::getVoidTy(Ctx), Type::getInt32Ty(Ctx));
    FunctionCallee logNext = F.getParent()->getOrInsertFunction(
        "log_next_state", Type::getVoidTy(Ctx));

    auto fname{F.getName()};
    if (fname.find("refinement") == std::string::npos)
      return false;

    errs() << "We are in refinement\n";

    auto *i = F.getEntryBlock().getFirstNonPHI();
    IRBuilder<> builder{i};

    // for (auto arg = F.arg_begin(); arg != F.arg_end(); ++arg) {
    //   if (auto *ci = dyn_cast<ConstantInt>(arg))
    //     errs() << ci->getValue() << "\n";
    //   errs() << *arg << "\n";
    // }

    for (auto &A : F.args()) {
      auto *ci = dyn_cast<Value>(&A);
      errs() << ci;
      builder.CreateCall(logPart, ci);
    }
    builder.CreateCall(logNext);

    errs() << F;
    return true;
  }
};

// Automatically enable the pass.
// http://adriansampson.net/blog/clangpass.html
void registerInstrumentorPass(const PassManagerBuilder &,
                              legacy::PassManagerBase &PM) {
  PM.add(new Instrumentor());
}
RegisterStandardPasses RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                                      registerInstrumentorPass);
} // namespace
char Instrumentor::ID = 0;

// static RegisterPass<Instrumentor> X("instrument",
//                                      "This instruments our source program",
//                                      false /* Only looks at CFG */,
//                                      false /* Analysis Pass */);
