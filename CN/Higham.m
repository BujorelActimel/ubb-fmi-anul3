function y = Higham(x)
    y = x;
    for i = 1:52, y = sqrt(y); end
    for i = 1:52, y = y.^2;   end
end
