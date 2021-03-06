source('../R/functions.R')

# Put true tree here
#tr_true <- chronopl(read.tree('set16_8.tree '), lambda = 0.5)
tr_true <- chronopl(rtree(50), lambda = 0.5)

tr_true$edge.length <- tr_true$edge.length / max(branching.times(tr_true))



dif = 1
while(dif != 2){

tr_q <- get_Q(tr_true, 2)

n_trans <- 0
while( n_trans < 2){
  tr_s <- sim.history(tr_true, tr_q)
  n_trans <- length(unique(get_node_states(tr_s)))
}


# Load estimated trees here
#est_trees <- lapply(1:10, function(x) rcoal(10))
#est_chrono <- list()
#for(i in 1:length(est_trees)){
#  est_chrono[[i]] <- est_trees[[i]]
#  est_chrono[[i]]$edge.length <- est_chrono[[i]]$edge.length / max(branching.times(est_chrono[[i]]))
#}
#class(est_chrono) <- 'multiPhylo'


est_chrono <- read.annotated.nexus('set16_8.trees.annotated')	
est_unl <- round(unlist(sapply(1:length(est_chrono$annotations), function(x) est_chrono$annotations[[x]]$posterior)), 2)
est_post <- c(est_unl[length(est_unl)], est_unl[2:(length(est_unl) - 1)], est_unl[length(est_unl)])

est_chrono <- chronopl(rSPR(tr_true), lambda = 0.5)
est_chrono$edge.length <- est_chrono$edge.length / max(branching.times(est_chrono))


#plot(est_chrono)
#nodelabels(est_post)

####
get_fitted_node_states <- function(reroot_tree){
  rec <- reroot_tree$marginal.anc
  marginal_anc <- colnames(rec)[sapply(1:nrow(rec), function(x) which.max(rec[x, ]))]
  return(marginal_anc)  
}
####

fit_true <- rerootingMethod(tr_true, tr_s$states, model = 'SYM')
true_nodes <- get_fitted_node_states(fit_true)
tips_true <- tr_s$states[match(tr_true$tip.label, names(tr_s$states))]
fit_states_true <- get_fitted_states(fit_true, tr_s$states, tr_true)
# NSTATES FOR TRUE HERE
n_states_true <- sum(sapply(1:nrow(fit_states_true), function(x) fit_states_true[x, 1] != fit_states_true[x, 2]))



#pdf('set16_8.pdf')
par(mfrow = c(1, 2))
plot(tr_true, show.tip.label = F)
tiplabels(tips_true, cex = 0.5, frame = 'circle', bg = factor(tips_true, ordered = T), col = 'white')
nodelabels(true_nodes, cex = 0.5, frame = 'circle', bg = factor(true_nodes, ordered = T), col = 'white')

fit_1 <- rerootingMethod(est_chrono, tr_s$states, model = 'SYM')
fit_nodes <- get_fitted_node_states(fit_1)
tip_states <- tr_s$states[match(est_chrono$tip.label, names(tr_s$states))] 
fit_states_1 <- get_fitted_states(fit_1, tip_states, est_chrono)
# NSTATES FOR MPE
n_states_1 <- sum(sapply(1:nrow(fit_states_1), function(x) fit_states_1[x, 1] != fit_states_1[x, 2]))

plot(est_chrono, show.tip.label = F)
tiplabels(tip_states, cex = 0.5, frame = 'circle', bg = factor(tip_states, ordered = T), col = 'white')
nodelabels(fit_nodes, cex = 0.5, frame = 'circle', bg = factor(fit_nodes, ordered = T), col = 'white')
nodelabels(est_post, adj = c(1.2, -1), frame = 'none', cex = 0.5)
#dev.off()

write.table(est_post, file = 'set16_8_post.txt')

# get Ntrans on random tree
print( n_states_1 / n_states_true)
dif <- n_states_1 / n_states_true

}
