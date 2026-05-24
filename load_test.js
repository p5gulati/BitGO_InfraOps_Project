import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m',  target: 500 },   // ramp up
    { duration: '2m',  target: 1000 },  // sustain for 5 minutes
    { duration: '1m',  target: 0 },     // ramp down
  ],
};

export default function () {
  http.get('https://paarth-infra.shop');
  sleep(1);
}