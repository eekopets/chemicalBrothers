function y = integrate_trapz(datarow,y0,h)
    x = datarow;
    N = length(x);
    y = zeros(1,N);
    y(1) = y0;
    h2 = 0.5*h;
    for i = 2:N
        y(i) = y(i-1) + h2*(x(i-1) + x(i));
    end
end