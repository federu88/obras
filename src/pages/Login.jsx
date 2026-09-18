import { useState } from 'react'
import { useAuth } from '../context/AuthContext'

export default function Login() {
  const { signIn } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  async function onSubmit(e) {
    e.preventDefault()
    setBusy(true)
    setError(null)
    const { error } = await signIn(email, password)
    if (error) setError(error.message)
    setBusy(false)
  }

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        padding: 16,
      }}
    >
      <form
        className="card"
        onSubmit={onSubmit}
        style={{ width: '100%', maxWidth: 380, display: 'grid', gap: 16 }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div className="brand-mark" style={{ width: 32, height: 32 }}>
            OB
          </div>
          <h1 style={{ fontSize: '1.25rem' }}>Obras</h1>
        </div>

        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          Gestión de desarrollo, construcción e inversión.
        </p>

        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            autoComplete="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <div className="field">
          <label htmlFor="password">Contraseña</label>
          <input
            id="password"
            type="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>

        {error && <div className="notice notice-error">{error}</div>}

        <button className="btn btn-primary" type="submit" disabled={busy}>
          {busy ? 'Entrando…' : 'Entrar'}
        </button>

        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          El alta de usuarios la hace un administrador. No hay registro abierto.
        </p>
      </form>
    </div>
  )
}
