import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSigningIn = false;
  String? _error;
  bool _isCreateAccount = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Email and password are required.';
        });
        return;
      }

      if (_isCreateAccount) {
        await AuthService.instance.createUserWithEmail(email, password);
      } else {
        await AuthService.instance.signInWithEmail(email, password);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = _formatAuthError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Sign in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = _formatAuthError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Google sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Post-it',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to sync your tasks across devices',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _signIn(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 260,
                child: FilledButton.icon(
                  onPressed: _isSigningIn ? null : _signIn,
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.email),
                  label: Text(_isSigningIn
                      ? 'Signing in...'
                      : _isCreateAccount
                          ? 'Create account'
                          : 'Sign in'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSigningIn
                    ? null
                    : () {
                        setState(() {
                          _isCreateAccount = !_isCreateAccount;
                          _error = null;
                        });
                      },
                child: Text(
                  _isCreateAccount
                      ? 'Already have an account? Sign in'
                      : 'Create an account',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'or',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 260,
                child: OutlinedButton.icon(
                  onPressed: _isSigningIn ? null : _signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Continue with Google'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'weak-password':
        return 'Password is too weak (min 6 chars).';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Auth error: ${e.code}';
    }
  }
}
