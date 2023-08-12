import Layout from "../components/layout"
import { useState } from 'react'
import { IDKitWidget } from "@worldcoin/idkit"
import type { ISuccessResult } from "@worldcoin/idkit";

const appId = "app_staging_bab24ffa02b5eceb09f302496b646dda";
const action = "test-action";

export default function IndexPage() {
	const [proof, setProof] = useState<ISuccessResult | null>(null);
  
  // This function will be called when the proof is received
  const handleVerify = (result: ISuccessResult) => {
		console.debug("handleVerify ", result);
    setProof(result);
  };
  
  // This function will be called when the widget is closed
  const onSuccess = (result: ISuccessResult) => {
    console.debug("onSuccess ", result);
  };

  return (
    <Layout>
      <h1>NextAuth.js Example</h1>
      <p>
        This is an example site to demonstrate how to use{" "}
        <a href="https://next-auth.js.org">NextAuth.js</a> with {" "}
        <a href ="https://worldcoin.org/world-id">World ID</a> for authentication.
      </p>
      <IDKitWidget
        app_id={appId} // obtained from the Developer Portal
        action={action} // this is your action name from the Developer Portal
        onSuccess={onSuccess} // callback when the modal is closed
        handleVerify={handleVerify} // optional callback when the proof is received
        // credential_types={['orb', 'phone']} // the credentials you want to accept
        // enableTelemetry // optional, defaults to false
      >
        {({ open }) => <button onClick={open}>Verify with World ID</button>}
      </IDKitWidget>
  </Layout>
  )
}
