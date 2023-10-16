import Intro from "./components/Intro/";
import Setup from "./components/Setup";
import Demo from "./components/Demo";
import Footer from "./components/Footer";
import { useContext, useEffect } from "react";
import { EthContext } from "./contexts/EthContext";

function App() {
  const context = useContext(EthContext);
  async function blabla() {
    await context.state.contract.methods.openProposalRegistration().call();
    const result = await context.state.contract.methods.currentSessionStatus().call();
    console.log(result);
  }
  useEffect(() => {
    if (!context.state.contract) return;
    blabla();
  }, [context.state.contract])

  return (
    <div id="App">
      <div className="container">
        <Intro />
        <hr />
        <Setup />
        <hr />
        <Demo />
        <hr />
        <Footer />
      </div>
    </div>
  );
}

export default App;
