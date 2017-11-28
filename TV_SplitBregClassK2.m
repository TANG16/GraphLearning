function [unew, energy,residual,error]=TV_SplitBregClassK2(FD0,Iset,u00,tol,G,maxit,mu,FD_ref)
% using K labelling functions
% min lambda \sum_i|Wu_i| .s.t u_i=FD0 on Ise,sum (u_i)=1 i_i\geq 0
tic;
% u=zeros(size(FD_ref));
[M,K] = size(u00);  %
d = cell(K,1);
b = cell(K,1);

deltab = cell(K,1);


% inititalize d and b, and compute normg
normg = 0;
for k=1:K
    d{k} = GraphGradientOperator(G,uold(:,k));;
    b{k} = d{k};
end

mu =0.08;

energy = zeros(maxit,1);
residual = zeros(maxit,1);
errors = zeros(maxit,1);

u = zeros(size(u00));

disp(['Initial is ',num2str(100*length(Iset(:))/M),'%'])
for nstep=1:maxit
    
    % update u
    for k=1:K
        u(:,k) = GraphGradientOperator;
    end
    % projection onto l1 ball
    for k = 1:K
        u(Iset(:,k),:) = 0; 
    end
    for k = 1:K
        u(Iset(:,k),k) = FD0(Iset(:,k),k);
    end
    u = projl1p_1D(u,1);

    % update d and b
    for k=1:K
        Wu{k} = W(u(:,k));%
        d{k} = CoeffOperGraph('s',CoeffOperGraph('+',Wu{k},b{k}),Thresh);
        
        deltab{k} = CoeffOperGraph('-',Wu{k},d{k});
        b{k} = CoeffOperGraph('+',b{k},deltab{k});

        % compute the energy and residual
        residual(nstep) = residual(nstep) + CoeffOperGraph('norm2',deltab{k})/normg;
        energy(nstep) = energy(nstep)+CoeffOperGraph('wnorm1',Wu{k},w);
    end

    % compute the errors if FD_ref is given
    [~,FDr] = max(u,[],2);%
    FDr = FDr-1;FDr(Iset(:)) = FD_ref(Iset(:));
    c=FDr==FD_ref;
    errors(nstep) = 100*(M-sum(c))/(M - length(Iset(:)));

    if residual(nstep)<tol
        break;
    end
    Tm=toc;
    if mod(nstep,20)==0
        display(['Step = ' num2str(nstep) '; Residual = ' num2str(residual(nstep)) '; Energy = ' num2str(energy(nstep)) '; Accuracy = ' num2str(100-errors(nstep)) '%; Time Elapsed = ' num2str(Tm)]);
    end
end
toc
% display('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
% display('Program Finished.')
% display(['Step = ' num2str(nstep) '; Residual = ' num2str(residual) '; errors = ' num2str(errors) '%; Time Elapsed = ' num2str(Tm)]);