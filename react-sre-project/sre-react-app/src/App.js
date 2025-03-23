import React, { useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import './App.css';
import HealthCheck from './components/HealthCheck';
import ErrorBoundary from './components/ErrorBoundary';
import metrics from './services/metrics';

// Home component
const Home = () => {
  useEffect(() => {
    metrics.trackNavigation('home');
  }, []);

  return (
    <div>
      <h1>SRE React Application - 1</h1>
      <p>Welcome to the SRE-instrumented React application</p>
    </div>
  );
};

// Dashboard component
const Dashboard = () => {
  useEffect(() => {
    metrics.trackNavigation('dashboard');
  }, []);

  return (
    <div>
      <h1>SRE Dashboard</h1>
      <p>This page shows SRE metrics for the application</p>
      <HealthCheck />
    </div>
  );
};

// ErrorTest component to simulate errors
const ErrorTest = () => {
  useEffect(() => {
    metrics.trackNavigation('error-test');
  }, []);

  const causeError = () => {
    throw new Error('This is a test error');
  };

  return (
    <div>
      <h1>Error Testing</h1>
      <p>Click the button below to trigger an error</p>
      <button onClick={causeError}>Trigger Error</button>
    </div>
  );
};

function App() {
  return (
    <ErrorBoundary>
      <Router>
        <div className="App">
          <nav>
            <ul>
              <li>
                <Link to="/">Home</Link>
              </li>
              <li>
                <Link to="/dashboard">SRE Dashboard</Link>
              </li>
              <li>
                <Link to="/error-test">Error Test</Link>
              </li>
            </ul>
          </nav>

          <Routes>
            <Route path="/dashboard" element={<Dashboard/>} />
            <Route path="/error-test" element={<ErrorTest/>} />
            <Route path="/" element={<Home/>} />
          </Routes>
        </div>
      </Router>
    </ErrorBoundary>
  );
}

export default App;
