import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s',  target: 200},   // ramp up
    { duration: '4m',  target: 1500 },  // sustain for 5 minutes
    { duration: '30s',  target: 0 },     // ramp down
  ],
};

export default function () {
  http.get('https://paarth-infra.shop');
  sleep(1);
}