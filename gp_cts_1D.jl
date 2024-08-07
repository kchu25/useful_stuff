using Random, LinearAlgebra, StatsBase, Plots

function kernel(x1, x2, λ, σ)
    return σ^2 * exp(-norm(x1 - x2)^2 / (2λ^2))
end

function create_covariance_matrix(X, λ, σ, noise)
    n = size(X, 1)
    K = zeros(n, n)
    for i in 1:n
        for j in 1:i
            K[i, j] = kernel(X[i, :], X[j, :], λ, σ)
            K[j, i] = K[i, j]
        end
        K[i, i] += noise^2
    end
    return K
end

function create_cross_covariance_matrix(X, X_new, λ, σ)
    n = size(X, 1)
    n_new = size(X_new, 1)
    K = zeros(n, n_new)
    for i in 1:n
        for j in 1:n_new
            K[i, j] = kernel(X[i, :], X_new[j, :], λ, σ)
        end
    end
    return K
end

# Set the random seed for reproducibility
Random.seed!(1234)

# Generate random input values
g(x) = 6sin.(x) .+ 0.0001 * x .^ 6 .- x
f(X) = g.(X) .+ randn(length(X)) * 0.1

n_samples = 55
n_test_samples = 150
X = randn(n_samples) .* 2
y = f(X)

λ = 2
σ = 25.0
noise = 12

X_test = collect(-8:0.01:8)

function return_essentials(X, X_test, y, λ, σ, noise)
    K = create_covariance_matrix(X, λ, σ, noise);
    K_starstar = create_covariance_matrix(X_test, λ, σ, 0.0);
    K_star_X = create_cross_covariance_matrix(X, X_test, λ, σ);
    K_inv = inv(K)
    mu(x) = (create_cross_covariance_matrix(X, x, λ, σ)' * inv(K) * y)[1,1]
    sig(x) = begin
        K_starstar = create_covariance_matrix(x, λ, σ, 0.0)
        K_star_X = create_cross_covariance_matrix(X, x, λ, σ)
        return ((K_starstar - K_star_X' * K_inv * K_star_X)[1,1] |> sqrt)[1,1]
    end
    return K, K_starstar, K_star_X, K_inv, mu, sig
end

K, K_starstar, K_star_X, K_inv, mu, sig = 
    return_essentials(X, X_test, y, λ, σ, noise)

μ = K_star_X' * K_inv * y
Σ = K_starstar - K_star_X' * K_inv * K_star_X


plot(X_test, f(X_test), label="True function")
plot!(X_test, μ, ribbon=sqrt.(diag(Σ)), fillalpha=0.2, label="Predictive distribution")
scatter!(X, y, label="Data")


# using Distributions
# pt = randn(1,1)
# n = Normal(0,1)

# x_star = f(X_test) |> maximum
# cdf(n, sum(pt))
# mu(pt)
# sig(pt)

# function ei(pt)
#     mu_here = mu(pt)
#     (mu_here - x_star)cdf()