import React, { useState, useEffect } from 'react';
import axios from 'axios';

const HealthCheck = () => {
  const [health, setHealth] = useState({
    status: 'Loading...',
    dependencies: [],
    uptime: 0,
  });

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const response = await axios.get('/api/health');
        console.log(response.data);
        setHealth(response.data);
      } catch (error) {
        setHealth({
          status: 'Unhealthy',
          dependencies: [],
          uptime: 0,
          error: error.message,
        });
      }
    };

    fetchHealth();
    const interval = setInterval(fetchHealth, 30000); // Check every 30 seconds
    
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="health-check">
      <h2>Application Health</h2>
      <p>Status: <span className={health?.status === 'Healthy' ? 'healthy' : 'unhealthy'}>
        {health.status}
      </span></p>
      
      {health?.dependencies?.length > 0 && (
        <>
          <h3>Dependencies:</h3>
          <ul>
            {health.dependencies.map((dep, index) => (
              <li key={index}>
                {dep.name}: {dep.status}
              </li>
            ))}
          </ul>
        </>
      )}
      
      <p>Uptime: {Math.floor(health.uptime / 60)} minutes</p>
      
      {health.error && (
        <div className="error-message">
          <p>Error: {health.error}</p>
        </div>
      )}
    </div>
  );
};

export default HealthCheck;
