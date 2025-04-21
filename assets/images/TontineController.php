<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Retrait;
use DatePeriod;
use DateInterval;
use Carbon\Carbon;
use App\Models\User;
use App\Logics\Helpers;
use App\Models\Requete;
use App\Models\Tontine;
use Carbon\CarbonPeriod;
use App\Models\Cotisation;
use Carbon\CarbonInterval;
use App\Models\Periodicite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\StatResource;
use App\Http\Resources\V1\MembreResource;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Validator;
use App\Http\Requests\StoreTontineRequest;
use App\Http\Resources\V1\RequeteResource;
use App\Http\Resources\V1\TontineResource;
use App\Http\Requests\UpdateTontineRequest;
use App\Http\Resources\V1\CotisationResource;
use App\Http\Resources\V1\PeriodiciteResource;
use Illuminate\Pagination\LengthAwarePaginator;
use App\Http\Resources\V1\UserTontineEtatResource;
use App\Http\Resources\V1\PeriodeCotisationResource;
use App\Models\Versement;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use app\Http\Controllers\Api\V1\IsPublicController;
use app\Http\Controllers\Api\V1\SharedTontineController;
class TontineController extends Controller
{


    public function __construct()
    {


    }

    /**
     * Display a listing of the resource.
     *
     * @return JsonResponse
     */
    public function index(Request $request)
    {
        $paginator = Tontine::with('user', 'users')
            ->where(function (Builder $query) use ($request) {
                return $query->where('user_id', $request->user()->id)->orWhereHas('users', function ($q) use ($request) {
                    $q->where('user_id', $request->user()->id);
                });
            })->withSum(['cotisations as montant_total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }])->withCount('periodicites as total_period')->orderBy("created_at", "DESC")
            ->paginate($request->limit, ['*'], 'page', $request->offset);


        return response()->json([
            'total_size' => $paginator->total(),
            'limit' => $request->limit,
            'offset' => $request->offset,
            'tontines' => TontineResource::collection($paginator->items())
        ]);
    }

    public function searchTontineByNumber(Request $request): JsonResponse
    {
        $tontines = Tontine::where('numero', $request->numero)->get();

        return response()->json([
            'error' => false,
            'tontines' => TontineResource::collection($tontines)
        ]);
    }

    public function lastTontine(Request $request): JsonResponse
    {
        $paginator = Tontine::with('user', 'users')
            ->where(function (Builder $query) use ($request) {
                return $query->where('user_id', $request->user()->id)->orWhereHas('users', function ($q) use ($request) {
                    $q->where('user_id', $request->user()->id);
                });
            })->withSum(['cotisations as montant_total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }])
            ->where('statut', '!=', 'FINISHED')
            ->orderBy("created_at", "DESC")
            ->paginate($request->limit, ['*'], 'page', $request->offset);

        return response()->json([
            'total_size' => $paginator->total(),
            'limit' => $request->limit,
            'offset' => $request->offset,
            'tontines' => TontineResource::collection($paginator->items())
        ]);
    }

    public function pendingTontine(Request $request): JsonResponse
    {

        $paginator = Tontine::with('user', 'users')
            ->where(function (Builder $query) use ($request) {
                return $query->where('user_id', $request->user()->id)->orWhereHas('users', function ($q) use ($request) {
                    $q->where('user_id', $request->user()->id);
                });
            })->withSum(['cotisations as montant_total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }])
            ->where('statut', "PENDING")
            ->orderBy("created_at", "DESC")
            ->paginate($request->limit, ['*'], 'page', $request->offset);


        return response()->json([
            'total_size' => $paginator->total(),
            'limit' => $request->limit,
            'offset' => $request->offset,
            'tontines' => TontineResource::collection($paginator->items())
        ]);
    }

    public function runningTontine(Request $request): JsonResponse
    {

        $paginator = Tontine::with('user', 'users')
            ->where(function (Builder $query) use ($request) {
                return $query->where('user_id', $request->user()->id)->orWhereHas('users', function ($q) use ($request) {
                    $q->where('user_id', $request->user()->id);
                });
            })->withSum(['cotisations as montant_total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }])->where('statut', "RUNNING")
            ->orderBy("created_at", "DESC")
            ->paginate($request->limit, ['*'], 'page', $request->offset);


        return response()->json([
            'total_size' => $paginator->total(),
            'limit' => $request->limit,
            'offset' => $request->offset,
            'tontines' => TontineResource::collection($paginator->items())
        ]);
    }

    public function finishedTontine(Request $request): JsonResponse
    {
        $paginator = Tontine::with('user', 'users')
            ->where(function (Builder $query) use ($request) {
                return $query->where('user_id', $request->user()->id)->orWhereHas('users', function ($q) use ($request) {
                    $q->where('user_id', $request->user()->id);
                });
            })->withSum(['cotisations as montant_total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
                $q->where('statut', 'PAID');
            }])->where('statut', "FINISHED")
            ->orderBy("created_at", "DESC")
            ->paginate($request->limit, ['*'], 'page', $request->offset);


        return response()->json([
            'total_size' => $paginator->total(),
            'limit' => $request->limit,
            'offset' => $request->offset,
            'tontines' => TontineResource::collection($paginator->items())
        ]);
    }

    public function getTontineMembre(Request $request, $id): JsonResponse
    {
        $membres = Tontine::find($id)->users;

        return response()->json([
            'error' => false,
            'message' => "",
            'membres' => MembreResource::collection($membres)
        ], 200);
    }

    public function getTontineCotisation(Request $request, $id): JsonResponse
    {
        if ($request->has('period') && $request->period != 0) {
            $cotisations = Tontine::find($id)->cotisations()->where(['statut' => "PAID", "periodicite_id" => $request->period])->get();
        } else {
            $cotisations = Tontine::find($id)->cotisations()->where('statut', "PAID")->get();

        }

        return response()->json([
            'error' => false,
            'message' => "",
            'cotisations' => CotisationResource::collection($cotisations)
        ], 200);
    }

    public function getTontineStats(Request $request, $id): JsonResponse
    {

        $stats = Tontine::find($id)->users()->select("id", "nom", "prenom")->withSum(['cotisations as montant' => function ($q) use ($id) {
            $q->where('tontine_id', $id)->groupBy('user_id');
        }], 'montant')->get();


        return response()->json([
            'error' => false,
            'message' => "",
            'stats' => StatResource::collection($stats)
        ], 200);
    }

    public function getPeriodicitesWithCotisationStatut(Request $request)
    {
        $periodicites = Periodicite::with(["cotisations" => function ($query) use ($request) {
            $query->where('user_id', '=', $request->user()->id);
        }])->get();

        return response()->json([
            'error' => false,
            'message' => "",
            'periodicites' => PeriodeCotisationResource::collection($periodicites)
        ], 200);
    }

    public function getTontinePeriodicite(Request $request, $id): JsonResponse
    {

        if ($request->has('withCotisation') && $request->withCotisation == 1) {

            $periodicites = Periodicite::with(["cotisations" => function ($query) use ($request) {
                $query->where('user_id', '=', $request->user()->id);
            }])->where("tontine_id", $id)->orderBy('libelle', "ASC")->get();


            foreach ($periodicites as $period) {
                if ($period->cotisations->count() > 0) {
                    foreach ($period->cotisations as $cotisation) {
                        if ($cotisation->statut == "PAID") {
                            $period->isPaid = 1;
                        } else {
                            $period->isPaid = 0;
                        }
                    }
                } else {
                    $period->isPaid = 0;
                }

            }

            return response()->json([
                'error' => false,
                'message' => "",
                'periodicites' => PeriodeCotisationResource::collection($periodicites)
            ], 200);

        } else {
            $periodicites = Tontine::find($id)->periodicites;

            return response()->json([
                'error' => false,
                'message' => "",
                'periodicites' => PeriodiciteResource::collection($periodicites)
            ], 200);
        }

    }

    public function getTontinePeriodiciteToPaid(Request $request, $id): JsonResponse
    {

        $tontine = Tontine::where('id', $id)->where(function ($q) {
            $q->where('statut', "RUNNING")->orWhere('statut', "FINISHED");
        })->first();

        $periodicites = Periodicite::with(['cotisations' => function ($query) {
            $query->where('statut', 'PAID');
        }])->where("tontine_id", $id) //doesntHave("versement")->
        ->orderBy('libelle', "ASC")->get();


        if ($tontine) {
            foreach ($periodicites as $period) {
                if ($period->cotisations->count() >= $tontine->nbre_personne) {
                    $period->statut = 1;
                }
            }
        }

        //dd($periodicites);

        return response()->json([
            'error' => false,
            'message' => "",
            'periodicites' => PeriodeCotisationResource::collection($periodicites)
        ], 200);


    }

    public function getUserTontineDetails(Request $request, $id, $user_id): JsonResponse
    {

        //Vérifié que celui qui veut l'information est un membre ou le propriétaire de la tontine
        $tontine = Tontine::find($id);

        //$user = User::find($user_id);

        $periodicites = $tontine->periodicites()->with('cotisations', function ($q) use ($user_id) {
            return $q->where("user_id", $user_id);
        })->get();


        return response()->json([
            'error' => true,
            'tontine_etats' => UserTontineEtatResource::collection($periodicites)
        ], 200);

    }


    public function getTontineRequetes($id, Request $request): JsonResponse
    {

        $requetes = Requete::with(['tontine' => function ($q) use ($request) {
            return $q->where('user_id', $request->user()->id);
        }])->where([
            'tontine_id' => $id,
            'type' => 'join_to_tontine',
            'statut' => "PENDING"
        ])->get();

        return response()->json([
            'error' => false,
            'requetes' => RequeteResource::collection($requetes)
        ]);
    }

    public function requestToCloseOrJoinTontine(Request $request, $id)
    {

        $validator = Validator::make($request->all(), [
            "type" => "required",
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors
            ], 400);
        }

        try {
            if ($request->type == "join_to_tontine") {
                $req = Requete::where(['user_id' => $request->user()->id, 'tontine_id' => $id])->first();

                if ($req) {
                    return response()->json([
                        'error' => true,
                        'message' => "Vous avez déjà soumis une demande d'adhésion."
                    ], 500);
                }

                $tontine = Tontine::find($id);

                if ($tontine->statut != "PENDING") {
                    return response()->json([
                        'error' => true,
                        'message' => "Cette épargne est en cours ou est terminée, vous ne pouvez pas soumettre de demande d'adhésion. Merci"
                    ], 500);
                }


                $requete = new Requete();

                $requete->type = $request->type;
                $requete->tontine_id = $id;
                $requete->user_id = $request->user()->id;
                $requete->statut = "PENDING";
                $requete->save();

                //Envoyer une notification au propriétaire de la tontine

                $data = [
                    'title' => "Epargne $tontine->numero",
                    'description' => "Bonjour, " . $request->user()->nom . " " . $request->user()->prenom . ", souhaite rejoindre votre épargne. Code: $tontine->numero.",
                    'tontine_id' => $tontine->id,
                    'image' => '',
                    'type' => 'request_status',
                ];

                Helpers::send_request_tontine_notification($tontine, $data, $tontine->user);


                return response()->json([
                    'error' => false,
                    'message' => "Votre demande a été envoyée avec succès"
                ], 201);

            } else if ($request->type == "close_tontine") {

                //Vérifiéé qu'il n'ya pas de paiement dans la tontine, aussi que tous les membres ont été payé
            }

        } catch (\Exception $e) {
            return response()->json([
                'error' => true,
                'message' => "Une erreur s'est produite"
            ], 500);
        }

    }


    public function acceptOrRejectMemberToTontine(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "request_id" => "required",
            "statut" => "required",
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors
            ], 400);
        }

        DB::beginTransaction();
        try {

            $requete = Requete::find($request->request_id);

            /*$requete->statut = $request->statut;
            $requete->save();*/

            $tontine = Tontine::where(['id' => $requete->tontine_id, 'statut' => 'PENDING'])->first();

            if ($request->statut == "ACCEPT") {

                if ($tontine) {
                    //Si le nombre de membres de la tontine est atteint on rejette l'utilisateur
                    $membre = $tontine->users()->where('user_id', $requete->user_id)->first();

                    if (count($tontine->users) == $tontine->nbre_personne) {

                        return response()->json([
                            'error' => true,
                            'message' => "Vous avez atteint le nombre de membre de la épargne."
                        ], 500);

                    } else if ($membre) {

                        return response()->json([
                            'error' => true,
                            'message' => "Cet utilisateur est déjà membre de la épargne."
                        ], 500);
                    }

                } else {
                    return response()->json([
                        'error' => true,
                        'message' => "Epargne en cours ou clôturée"
                    ], 500);
                }

                $ordre = count($tontine->users) + 1;
                $tontine->users()->attach([$requete->user_id => ['ordre' => $ordre]]);

                $requete->statut = $request->statut;
                $requete->save();

                DB::commit();
                //Envoyer une notification l'utiliseur pour lui dire que sa demande a été acceptée

                $data = [
                    'title' => "Epargne $tontine->numero",
                    'description' => "Bonjour, " . $requete->user->nom . " " . $requete->user->prenom . ", votre demande de rejoindre la épargne code: $tontine->numero a été acceptée avec succès.",
                    'tontine_id' => $tontine->id,
                    'image' => '',
                    'type' => 'request_status',
                ];

                Helpers::send_request_tontine_notification($tontine, $data, $requete->user);

                return response()->json([
                    'error' => false,
                    'message' => "Membre ajouté avec succès"
                ], 200);
            } else if ($request->statut == "REJECT") {

                $requete->statut = $request->statut;
                $requete->save();

                //Envoyer une notification l'utiliseur pour lui dire que sa demande a été rejetée

                $data = [
                    'title' => "Epargne $tontine->numero",
                    'description' => "Bonjour, " . $requete->user->nom . " " . $requete->user->prenom . ", votre demande de rejoindre la épargne code: $tontine->numero a été rejetée.",
                    'tontine_id' => $tontine->id,
                    'image' => '',
                    'type' => 'tontine_status',
                ];

                Helpers::send_request_tontine_notification($tontine, $data, $requete->user);

                DB::commit();

                return response()->json([
                    'error' => false,
                    'message' => "Demande rejeté avec succès"
                ], 200);
            }


        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'error' => true,
                'message' => "Une erreur s'est produite"
            ], 500);
        }

    }

    public function makePayment(Request $request)
    {
        $users[] = $request->user();
        //dd($request->user());

        $cotisations = Cotisation::where('statut', 'PENDING')
            ->where('provider', 'moov money')
            ->whereDate("created_at", '>=', Carbon::now()->subDays(1))
            ->whereDate("created_at", '<=', Carbon::now())
            ->get();

        if ($cotisations->count() > 0) {
            $resp = [];
            foreach ($cotisations as $cotisation) {
                $response = Helpers::moov_money_debit("", "", $cotisation->trans_id, "check_transaction");
                $resp[] = $response;
                //$response = json_decode($response);
                /*if ($response->status == "0") {
                    $cotisation->update([
                        "statut" => "PAID",
                        //"provider_trans_id" => $response->{'trans-id'},
                    ]);
                    $period = Periodicite::find($cotisation->periodicite_id);

                    Helpers::send_cotisation_notification($cotisation->tontine, $cotisation->user, $period->libelle);
                }*/
            }
            return $resp;
        }

        return 0;

    }


    public function cotiser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "tontine" => 'required|numeric',
            "periode" => 'required|numeric',
            "montant" => 'required|numeric',
            "provider" => 'required',
            "telephone" => "required",
            "code_otp" => "required"
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors,
                'message' => "Veuillez renseignez tous les champs."
            ], 400);
        }

        Log::debug("DONNEES ENVOYEES PAR L'APPLI => " . json_encode($request->all()));


        DB::beginTransaction();
        try {

            $tontine = Tontine::find($request->tontine);

            $cotisation = new Cotisation();
            $cotisation->trans_id = "FAT" . date('dmy') . "-" . time();
            $cotisation->tontine_id = $request->tontine;
            $cotisation->provider = $request->provider;
            $cotisation->telephone = $request->telephone;
            $cotisation->code_otp = $request->code_otp;
            $cotisation->periodicite_id = $request->periode;
            $cotisation->montant = $request->montant - $tontine->frais;
            $cotisation->montant_tontine_frais = $request->montant;
            $cotisation->user_id = $request->user()->id;

            if($request->provider == "orange money"){
                $response = Helpers::intouch_debit($request->telephone, $request->code_otp, $request->montant, $cotisation->trans_id);
                $response = json_decode($response);

                Log::debug("REPONSE DE INTOUCH => ".json_encode($response));
                if($response->status == "SUCCESSFUL"){
                    $cotisation->provider_trans_id = $response->numTransaction;
                    $cotisation->statut = "PAID";
                    $cotisation->save();
                    DB::commit();


                    $period = Periodicite::find($request->periode);
                    Helpers::send_cotisation_notification($tontine, $request->user(), $period->libelle);

                    $telephone = Helpers::get_settings("telephone_mobile");

                    Log::debug("SUCCES DU PAIEMENT");
                    return response()->json([
                        'error' => false,
                        'message' => "Cotisation effectuée avec succès",
                        'cotisation' => new CotisationResource($cotisation)
                    ], 201);
                }else{
                    Log::error("ERREUR STATUT INTOUCH  => ".json_encode($response));
                    DB::rollBack();
                    return response()->json([
                        'error' => true,
                        'message' => "Echec de la transaction. Veuillez vérifier vos informations de paiement et réessayer. status => ".$response->status
                    ], 500);
                }

            }else if($request->provider == "moov money"){
                    DB::rollBack();
                    return response()->json([
                        'error' => true,
                        'message' => "Echec de la transaction. Veuillez vérifier vos informations de paiement et réessayer.",
                    ], 500);
                /*$cotisations = Cotisation::where('statut', 'PENDING')
                        ->where('provider', 'moov money')
                        ->where('periodicite_id', $request->periode)
                        ->where('user_id', $request->user()->id)
                        ->where('tontine_id', $request->tontine)
                        ->get();
                //$cotisation->statut = "PAID";
                if($cotisations->count() > 0){
                    foreach($cotisations as $cotisation){
                        $cotisation->update(['statut' => "UNPAID"]);
                    }
                }

                $response = Helpers::moov_money_debit($request->telephone, $request->montant, $cotisation->trans_id, "merchant_payment");
                $response = json_decode($response);
                if($response->status == "0"){
                    $cotisation->provider_trans_id = $response->{'trans-id'};
                    $cotisation->statut = "PENDING";
                    $cotisation->save();
                    DB::commit();

                    $users[] = $request->user();
                    Helpers::send_notification($users, $request->tontine, "Paiement en attente", "Suivez les instructions sur Moov Money pour finaliser votre cotisation. Merci");

                    return response()->json([
                        'error' => false,
                        'message' => "Votre Cotisation sera pris en compte une fois le paiement validé.",
                        'cotisation' => new CotisationResource($cotisation)
                    ], 201);
                }else{
                    DB::rollBack();
                    return response()->json([
                        'error' => true,
                        'message' => "Echec de la transaction. Veuillez vérifier vos informations de paiement et réessayer.",
                    ], 500);
                }*/
            }

        } catch (\Exception $e) {
            Log::error("ERREUR D'EXCEPTION  => " . $e->getMessage());
            DB::rollBack();
            return response()->json([
                'error' => true,
                'message' => "Une erreur s'est produite. Vueillez réessayer...",
            ], 500);
        }

    }

    public function updateTontineStatut($id, Request $request)
    {
        $validator = Validator::make($request->all(), [
            "statut" => 'required',
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'message' => "Veuillez vérifier tous les champs",
                'error' => $errors
            ], 400);
        }

        Tontine::find($id)->update(['statut' => $request->statut]);

        $tontine = Tontine::withSum('cotisations as montant_total_cotisation', 'montant')
            ->withCount('cotisations as total_cotisation')
            ->where('id', $id)->first();

        if ($request->statut == "RUNNING") {

            //géneration de la périodicité
            if ($tontine->users->count() > 0) {
                $periodicites = $this->generatePeriode($tontine->periodicite, $tontine->date_debut, $tontine->date_fin);

                foreach ($periodicites as $key => $period) {
                    $periodicite = new Periodicite();
                    $periodicite->tontine_id = $request->id;
                    $periodicite->libelle = $period;
                    //$periodicite->user_id = $tontine->type == "EPARGNE COLLECTIVE" ? $tontine->users[$key]->id : $request->user()->id;
                    $periodicite->is_begin = $key == 0 ? 1 : 0;
                    $periodicite->is_end = $key == count($periodicites) ? 1 : 0;
                    $periodicite->save();
                }
            }
        }

        Helpers::send_tontine_notification($tontine);

        return response()->json([
            'error' => false,
            'message' => "Statut changé avec succès..",
            'tontine' => new TontineResource($tontine)
        ], 200);
    }


    public function addMembre($id, Request $request)
    {
        $validator = Validator::make($request->all(), [
            "membres" => "array",
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors
            ], 400);
        }


        try {
            $tontine = Tontine::findOrFail($id);
        } catch (\Exception $e) {
            return response()->json([
                'error' => false,
                'message' => "Cette épargne n'existe pas!"
            ], 404);
        }


        if ($tontine->user_id != $request->user()->id) {
            return abort(401, "Vous n'êtes pas autorisé à accéder à cette ressource");
        }


        if (count($request->membres) > 0) {

            $data = [];
            $ids = [];
            foreach ($request->membres as $membre) {
                $data[$membre['id']] = array("ordre" => $membre['ordre']);
                $ids[] = $membre['id'];
            }
            $tontine->users()->sync($data);

            $tontine = Tontine::findOrFail($id);


            $membres = $tontine->users()->whereIn('id', $ids)->get();


            Helpers::send_add_or_delete_membre_notification($tontine, $membres);

        }

        return response()->json([
            'error' => false,
            'message' => "Membres ajoutés avec succès.",
            'tontine' => new TontineResource($tontine)
        ], 201);
    }


    public function deleteMembre($id, $membre, Request $request)
    {

        $tontine = Tontine::findOrFail($id);

        if ($tontine->user_id == $request->user()->id || $request->user()->id == $membre) {
            $tontine->users()->detach($membre);

            $membres = $tontine->users()->orderBy('pivot_ordre', 'ASC')->get();

            $i = 1;
            foreach ($membres as $membre) {
                $tontine->users()->updateExistingPivot($membre->id, ['ordre' => $i]);
                $i++;
            }

            $user = User::find($membre);
            $membres[] = $user;
            Helpers::send_add_or_delete_membre_notification($tontine, $membres, true);

            return response()->json([
                'error' => false,
                'message' => "Membre supprimé avec succès.",
            ], 200);
        } else {
            return response()->json([
                'error' => true,
                'message' => "Vous n'êtes pas autorisé à accéder à cette ressource.",
            ], 401);
        }

    }

    /**
     * Store a newly created resource in storage.
     *
     * @param \App\Http\Requests\StoreTontineRequest $request
     * @return JsonResponse
     */
    public function store(StoreTontineRequest $request)
    {
        $validator = Validator::make($request->all(), $request->rules());

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors
            ], 400);
        }
        $data = $request->all();
        $data['numero'] = 'FT' . $this->generateCode();
        $data['statut'] = "PENDING";
        $data['user_id'] = $request->user()->id;
        $tontine = Tontine::create($data);

        if ($data['type'] != "EPARGNE COLLECTIVE" || $tontine->type != "GROUPE") {
            $tontine->users()->attach([
                $request->user()->id => ['ordre' => 1]
            ]);
        }

        return response()->json([
            'error' => false,
            'message' => "Epargne créée avec succès.",
            'code' => $tontine->numero,
            'tontine' => new TontineResource($tontine)
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param id
     * @return JsonResponse
     */
    public function show($id)
    {
        $tontine = Tontine::withSum(['cotisations as montant_total_cotisation' => function ($q) {
            $q->where('statut', 'PAID');
        }], 'montant')->withCount(['cotisations as total_cotisation' => function ($q) {
            $q->where('statut', 'PAID');
        }])->withCount('periodicites as total_period')->where('id', $id)->first();

        return response()->json([
            'error' => false,
            'message' => "Epargne récupéré avac succès",
            'tontine' => new TontineResource($tontine)
        ]);


    }

    /**
     * Update the specified resource in storage.
     *
     * @param UpdateTontineRequest $request
     * @param Tontine $tontine
     * @return JsonResponse
     */
    public function update(UpdateTontineRequest $request, $id)
    {
        $validator = Validator::make($request->all(), $request->rules());

        if ($validator->fails()) {
            $errors = $validator->errors();
            return response()->json([
                'error' => $errors
            ], 400);
        }

        $tontine = Tontine::find($id);
        //dd($tontine->cotisations);
        if ($tontine->statut == "RUNNING" && count($tontine->cotisations) == 0) {
            //On supprime toutes les periodicites et on regenere
            $tontine->periodicites()->delete();
            //dd($tontine->periodicites);
            if ($tontine->users->count() > 0) {

                $periodicites = $this->generatePeriode($request->periodicite, $request->date_debut, $request->date_fin);

                foreach ($periodicites as $key => $period) {
                    $periodicite = new Periodicite();
                    $periodicite->tontine_id = $tontine->id;
                    $periodicite->libelle = $period;
                    //$periodicite->user_id = $tontine->type == "EPARGNE COLLECTIVE" ? $tontine->users[$key]->id : $request->user()->id;
                    $periodicite->is_begin = $key == 0 ? 1 : 0;
                    $periodicite->is_end = $key == count($periodicites) ? 1 : 0;
                    $periodicite->save();
                }
                //dd($periodicites);
            }

            $tontine->type = $request->type;
            $tontine->libelle = $request->libelle;
            $tontine->nbre_personne = $request->nbre_personne;
            $tontine->periodicite = $request->periodicite;
            $tontine->montant_tontine = $request->montant_tontine;
            $tontine->montant_tontine_frais = $request->montant_tontine_frais;
            $tontine->frais = $request->frais;
            $tontine->date_debut = $request->date_debut;
            $tontine->date_fin = $request->date_fin;
            $tontine->description = $request->description;
            $tontine->isPublic = $request->isPublic;


            $tontine->save();
            return $tontine;
        } elseif ($tontine->statut == "RUNNING" && count($tontine->cotisations) > 0) {

            $periodicite_count = $tontine->periodicites->count();
            $cotisation_count = $tontine->cotisations->count();
            $cotisation_sum = $tontine->cotisations->sum('montant');

            if ($tontine->type == "EPARGNE COLLECTIVE" || $tontine->type == "GROUPE") {
                $total = ($tontine->nbre_personne * $periodicite_count * $tontine->montant_tontine) - $cotisation_sum;
                if ($total == 0) {
                    return response()->json([
                        'error' => true,
                        'message' => "Vous ne pouvez plus modifier cette épargne. Elle est surement cloturee. Veuillez contacter l'administrateur.",
                    ], 400);
                }
            } else {
                if ($periodicite_count == $cotisation_count) {
                    return response()->json([
                        'error' => true,
                        'message' => "Vous ne pouvez plus modifier cette épargne. Elle est surement cloturee. Veuillez contacter l'administrateur.",
                    ], 400);
                }
            }

            $tontine->libelle = $request->libelle;
            $tontine->montant_tontine = $request->montant_tontine;
            $tontine->montant_tontine_frais = $request->montant_tontine_frais;
            $tontine->frais = $request->frais;
            $tontine->description = $request->description;
            $tontine->isPublic = $request->isPublic;


            $tontine->save();

        } else if ($tontine->statut == "PENDING") {
            $tontine->type = $request->type;
            $tontine->libelle = $request->libelle;
            $tontine->nbre_personne = $request->nbre_personne;
            $tontine->periodicite = $request->periodicite;
            $tontine->montant_tontine = $request->montant_tontine;
            $tontine->montant_tontine_frais = $request->montant_tontine_frais;
            $tontine->frais = $request->frais;
            $tontine->date_debut = $request->date_debut;
            $tontine->date_fin = $request->date_fin;
            $tontine->description = $request->description;
            $tontine->isPublic = $request->isPublic;

            $tontine->save();
        } else {
            return response()->json([
                'error' => true,
                'message' => "Vous ne pouvez plus modifier cette épargne. Elle est surement cloturee. Veuillez contacter l'administrateur.",
            ], 400);
        }


        return response()->json([
            'error' => false,
            'message' => "Epargne modifiée avec succès.",
            'tontine' => new TontineResource($tontine)
        ]);

    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function retrait(Request $request): JsonResponse
    {
        if (!$request->has('membre')) {
            $validator = Validator::make($request->all(), [
                "tontine" => "required",
                'montant' => 'required',
                'operateur' => 'required',
                'numero' => 'required',
                'nom_compte' => 'required',
            ]);

            if ($validator->fails()) {
                $errors = $validator->errors();
                return response()->json([
                    'error' => $errors
                ], 400);
            }

            $data = $request->all();
            $tontine = Tontine::find($data['tontine']);

            if (!empty($tontine->cotisations)) {
                $retrait = Retrait::where('tontine_id', $data['tontine'])->first();
                if (!$retrait) {
                    $totalMontant = $tontine->montant_tontine * $tontine->nbre_personne * $tontine->nbre_periode;
                    if ($data['montant'] < $totalMontant) {
                        $data['penalite'] = $data['montant'] * 0.1;
                    }
                    Retrait::create([
                        "tontine_id" => $data['tontine'],
                        "montant" => $data['montant'],
                        "operateur" => $data['operateur'],
                        "numero" => $data['numero'],
                        "nom_compte" => $data['nom_compte'],
                        "penalite" => $data['penalite'] ?? 0,
                        "statut" => "non paye",
                    ]);
                    //Helpers::send_sms(Helpers::format_phone($request->user()->telephone), "Votre requete est en cours de traitement, vous recevrez votre paiement dans un delai de 24h.");

                    $details = [
                        'title' => "Tontine n° $tontine->numero",
                        'body' => 'Nous demandons le transfert de la somme de ' . $data['montant'] . ' Fcfa au numéro ' . $data['operateur'] . ' <<' . $data['numero'] . '>>.Le nom du compte est <<' . $data['nom_compte'] . '>>.'
                    ];

                    $email = Helpers::get_settings("email");
                    Mail::to($email)->send(new \App\Mail\RetraitEmail($details));

                    return response()->json([
                        'error' => false,
                        'message' => "Votre demande est en cours de traitement"
                    ]);


                } else {
                    if ($retrait->statut == "paye") {
                        return response()->json([
                            'error' => true,
                            'message' => "Cette épargne a déjà été payée"
                        ], 400);
                    }
                    return response()->json([
                        'error' => true,
                        'message' => "Une demande est déjà en cours pour cette épargne. Merci"
                    ], 400);

                }
            } else {
                return response()->json([
                    'error' => true,
                    'message' => "Vous n'avez effectué aucune cotisation pour le moment. Veuillez verifier que votre application est a jour. Merci",
                ], 400);
            }
        } else {
            $validator = Validator::make($request->all(), [
                'tontine' => 'required',
                'membre' => 'nullable',
                'numero_membre' => 'nullable',
                'periode' => 'nullable',
                'montant' => 'required',
                'moyen_paiement' => 'required',
                'numero_paiement' => 'required',
                'nom_compte_mobile' => 'required',
            ]);

            if ($validator->fails()) {
                $errors = $validator->errors();
                return response()->json([
                    'error' => $errors
                ], 400);
            }

            $data = $request->all();

            $tontine = Tontine::find($data['tontine']);
            if (!empty($tontine->cotisations)) {
                if ($tontine->type == "GROUPE") {
                    $vers = Versement::where(['tontine_id' => $data['tontine'], 'periodicite_id' => $data['periode']])->first();
                    $message = "Une demande est déjà en cours pour cette périodicité. Merci";
                } else {
                    $vers = Versement::where('tontine_id', $data['tontine'])->first();
                    $message = "Une demande est déjà en cours pour cette tontine. Merci";
                }
            } else {
                return response()->json([
                    'error' => true,
                    'message' => "Vous n'avez effectué aucune cotisation pour le moment. Veuillez verifier que votre application est a jour. Merci",
                ], 400);
            }


            if ($vers) {

                return response()->json([
                    'error' => true,
                    'message' => $message,
                ], 400);

            } else {

                $data['user_id'] = $request->user()->id;

                $user = User::find($data['membre']);
                $period = Periodicite::find($data['periode']);


                $versement = Versement::create([
                    "tontine_id" => $data['tontine'],
                    "user_id" => $data['membre'],
                    "periodicite_id" => $data['periode'],
                    "montant" => $data['montant'],
                    "numero_membre" => $data['numero_membre'],
                    "moyen_paiement" => $data['moyen_paiement'],
                    "numero_paiement" => $data['numero_paiement'],
                    "nom_compte_mobile" => $data['nom_compte_mobile']
                ]);


                if ($tontine->type == "GROUPE") {
                    $body = 'Nous demandons le transfert de la somme de ' . $data['montant'] . ' Fcfa au membre ' . $user->nom . ' ' . $user->prenom . ' au numéro ' . $data['moyen_paiement'] . ' <<' . $data['numero_paiement'] . '>> comptant pour la période <<' . $period->libelle . '>>. Le nom du compte est <<' . $data['nom_compte_mobile'] . '>>.';
                } else {
                    $body = 'Nous demandons le transfert de la somme de ' . $data['montant'] . ' Fcfa au numéro ' . $data['moyen_paiement'] . ' <<' . $data['numero_paiement'] . '>>.
                Le nom du compte est <<' . $data['nom_compte_mobile'] . '>>.';
                }

                $details = [
                    'title' => "Tontine n° $tontine->numero",
                    'body' => $body
                ];

                $email = Helpers::get_settings("email");

                $d = [
                    'title' => "Tontine $tontine->numero",
                    'description' => "Votre requete est en cours de traitement, vous recevrez votre paiement dans un delai de 24h.",
                    'tontine_id' => $tontine->id,
                    'image' => '',
                    'type' => 'tontine_status',
                ];

                //Helpers::send_request_tontine_notification($tontine, $d, $request->user);
                Helpers::send_sms(Helpers::format_phone($request->user()->telephone), "Votre requete est en cours de traitement, vous recevrez votre paiement dans un delai de 24h.");


                Mail::to($email)->send(new \App\Mail\RetraitEmail($details));

                return response()->json([
                    'error' => false,
                    'message' => "Votre requête a été envoyée avec succès. Merci",
                ]);
            }
        }

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param Tontine $tontine
     * @return JsonResponse
     */
    public function destroy(Tontine $tontine): JsonResponse
    {
        $tontine->delete();

        return response()->json([
            'error' => false,
            'message' => "Epargne supprimée avec succès. Merci",
        ]);
    }

    private function generateCode(int $length = 8, string $keyspace = "0123456789"): string
    { //abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
        if ($length < 1) {
            throw new \RangeException("La taille doit être une valeur positive");
        }
        $pieces = [];
        $max = mb_strlen($keyspace, '8bit') - 1;
        for ($i = 0; $i < $length; $i++) {
            $pieces[] = $keyspace[random_int(0, $max)];
        }
        return implode('', $pieces);
    }


    public function paginate($items, $perPage = 4, $page = null)
    {
        $page = $page ?: (LengthAwarePaginator::resolveCurrentPage() ?: 1);
        $total = count($items);
        $currentpage = $page;
        $offset = ($currentpage * $perPage) - $perPage;
        $itemstoshow = array_slice($items, $offset, $perPage);
        return new LengthAwarePaginator($itemstoshow, $total, $perPage);
    }

    public function generatePeriode($periodicite, $from, $to): array
    {
        if ($periodicite == "JOURNALIERE") {
            $days = 1;
        } else if ($periodicite == "HEBDOMADAIRE") {
            $days = 7;
        } else if ($periodicite == "MENSUELLE") {
            $days = 30;
        } else if ($periodicite == "TRIMESTRIELLE") {
            $days = 90;
        }

        $interval = CarbonInterval::days($days);
        $periods = CarbonPeriod::create($from, $interval, $to);
        $dates = [];

        foreach ($periods as $date) {
            $dates[] = $date->format('Y-m-d');
        }
        return $dates;
        
    }
 
    /**
     * Récupère les épargnes partagées (isPublic = true).
     *
     * @return JsonResponse
     */
    public function getSharedTontines(): JsonResponse
    {
        // Récupérer toutes les épargnes où isPublic = true
        $tontine = Tontine::where('isPublic', true)->get();

        return response()->json([
            'error' => false,
            'message' => 'Épargnes partagées récupérées avec succès.',
            'tontine' => $tontine,
        ], 200);
    }


    /*User::join('locations as l', 'users.location_id', '=', 'l.id')
        ->select('users.*', DB::raw('(6371 * acos(cos(radians(' . $coordinates['latitude'] . ')) * cos(radians(`lat`)) * cos(radians(`lng`) - radians(' . $coordinates['longitude'] . ')) + sin(radians(' . $coordinates['latitude'] . ')) * sin(radians(`lat`)))) as distances'))
        ->having('distances', '<', $max_distance)
        ->orderBy('distances', 'ASC')
        ->where('role_id',2)
        ->whereNotIn('id', $blockeduser)
        ->simplePaginate(20);*/
}
