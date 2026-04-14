import { RouterProvider } from 'react-router';
import { router } from './routes';

export default function App() {
  // Triggering HMR
  return <RouterProvider router={router} />;
}
